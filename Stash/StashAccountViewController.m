#import "StashAccountViewController.h"

#import "StashIssuesManager.h"
#import "StashNetworkManager.h"

#import "StashPopoverWindowController.h"
#import "StashRepoTableCellView.h"
#import "StashView.h"

#import <QuartzCore/QuartzCore.h>

#import "NSObject+BlockObservation.h"
#import "NSArray+UntestedIndex.h"
#import "NSString+Additions.h"
#import "NSString+ScoreForAbbreviation.h"
#import "NSString+KeyCodeTranslator.h"

#import "qLog.h"


NSString * const StashRepoTableCellViewIdentifier = @"StashRepoTableCellViewIdentifier";
NSString * const StashRepoListSelectionIdentifier = @"StashRepoListSelectionIdentifier";


@interface StashAccountViewController ()

@property (strong) IBOutlet NSScrollView *reposCollectionScrollView;
@property (strong) IBOutlet NSTableView *reposTableView;
@property (strong) IBOutlet NSSearchField *filterField;
@property (strong) IBOutlet StashView *filterBackgroundView;

@property (copy, nonatomic) NSString *filterString;

@property (strong) NSArray *repos;
@property (strong) NSMutableArray *observationTokens;

@end


@implementation StashAccountViewController


- (void)awakeFromNib
{	
	self.filterField.delegate = self;
	self.filterBackgroundView.backgroundColor = [NSColor colorWithDeviceHue:0.639 saturation:0.011 brightness:0.963 alpha:1.000];
	
	NSColor *backgroundColor = [NSColor whiteColor];
	NSScrollView *reposCollectionScrollView = self.reposCollectionScrollView;
	[reposCollectionScrollView setBackgroundColor:backgroundColor];
	[reposCollectionScrollView setScrollerStyle:NSScrollerStyleOverlay];
	
	NSTableView *reposTableView = self.reposTableView;
	reposTableView.rowHeight = 32.0;
	reposTableView.delegate = self;
	reposTableView.dataSource = self;
	[reposTableView setNeedsDisplay];
		
	__weak StashAccountViewController *accountViewController = self;
	[(StashView *)self.view setKeyEventHandlingBlock:^(NSEvent *keyEvent, BOOL *shouldCallSuper) {
		*shouldCallSuper = [accountViewController handleKeyEvent:keyEvent];
	}];
}


- (void)setFilterString:(NSString *)filterString
{
	_filterString = filterString;
	
	[self updateContent:TRUE];
	
	if(filterString.length == 0) {
		[self.reposTableView deselectAll:nil];
	}
}


- (void)viewWillAppear:(BOOL)animated
{
	NSMutableArray *observationTokens = [self observationTokens] ? : [[NSMutableArray alloc] init];
	__weak StashAccountViewController *accountViewController = self;
	
	id token = [[StashIssuesManager sharedIssuesManager] sk_observeKeyPath:@"currentAccount.repos" change:^(id observedObject, NSString *keyPath, id oldValue, id newValue) {
		[accountViewController updateContent:FALSE];
	}];
	
	if(token)
		[observationTokens addObject:token];
	
	[self updateContent:FALSE];
	
	// Restore the previous selection
//	NSUInteger repoInteger = [[NSUserDefaults standardUserDefaults] integerForKey:StashRepoListSelectionIdentifier];
//	
//	if(repoInteger > 0) { 
//		NSUInteger selectionIndex = 0;
//		
//		for(StashRepo *repo in self.repos) {
//			if(repo.identifier.integerValue == repoInteger) {
//				[self.reposTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectionIndex] byExtendingSelection:FALSE];
//				break;
//			}
//			
//			selectionIndex++;
//		}
//	}
}


- (void)viewDidAppear:(BOOL)animated
{
	[self.view.window makeFirstResponder:self.view];
}


- (void)viewWillDisappear:(BOOL)animated
{
	for(id observationToken in self.observationTokens)
		[NSObject sk_removeObservationForToken:observationToken];
	
	// Save the current selection
	StashRepo *repo = [self.repos objectAtUntestedIndex:self.reposTableView.selectedRow];
	NSUInteger repoInteger = [repo.identifier integerValue];
	[[NSUserDefaults standardUserDefaults] setInteger:repoInteger forKey:StashRepoListSelectionIdentifier];
}


- (void)updateContent:(BOOL)selectFirstItem
{
	NSString *filterString = self.filterString;
	NSString *predicateFormat = nil;
	NSArray *arguments = nil;
	
	if([filterString length]) {
		__block NSMutableString *abbreviationMatchingRegex = [[NSMutableString alloc] initWithString:@".*"];
		__block NSCharacterSet *regularExpressionCharactersToEscape = [NSCharacterSet characterSetWithCharactersInString:@"\\.+*?[^]$(){}=!<>|:-"];
		
		[[filterString normalizedString] enumerateSubstringsInRange:NSMakeRange(0, [filterString length])
														 options:NSStringEnumerationByComposedCharacterSequences
													  usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			if([substring rangeOfCharacterFromSet:regularExpressionCharactersToEscape].location != NSNotFound)
				[abbreviationMatchingRegex appendString:@"\\"];
			
			[abbreviationMatchingRegex appendString:substring];
			[abbreviationMatchingRegex appendString:@".*"];
		}];
		
		
		predicateFormat = @"name MATCHES[cd] %@";
		arguments = @[abbreviationMatchingRegex];
	}
	
	
	NSArray *repos = [[StashIssuesManager sharedIssuesManager] fetchObjectsOfEntityName:[StashRepo entityName] matching:predicateFormat argumentArray:arguments sortDescriptors:nil];
	repos = [self sortedArrayOfRepos:repos usingAbbreviation:filterString];
	self.repos = repos;
	
	NSTableView *reposTableView = self.reposTableView;
	[reposTableView reloadData];
	
	if(selectFirstItem && [repos count]) {
		[reposTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:FALSE];
	}
}


- (NSArray *)sortedArrayOfRepos:(NSArray *)repos usingAbbreviation:(NSString *)abbreviation
{
	if([abbreviation length]) {
		// Sort by the abbreviation score
		for(StashRepo *repo in repos) {
			// Happily clobber any existing scoreForAbbreviation or maskForAbbreviation
			NSMutableIndexSet *mask = [[NSMutableIndexSet alloc] init];
			repo.scoreForAbbreviation = [[repo.name normalizedString] scoreForAbbreviation:abbreviation hitMask:&mask];
			repo.maskForAbbreviation = [mask copy];
		}
		
		repos = [repos sortedArrayUsingComparator:^NSComparisonResult(StashRepo *firstRepo, StashRepo *secondRepo) {
			//
			if(![firstRepo isKindOfClass:[StashRepo class]] || ![secondRepo isKindOfClass:[StashRepo class]]) {
				qLog(@"Unexpected object types in comparison: %@ - %@. Expecting StashRepo's", firstRepo, secondRepo);
				return NSOrderedSame;
			}
			
			CGFloat firstElementRating = firstRepo.scoreForAbbreviation;
			CGFloat secondElementRating = secondRepo.scoreForAbbreviation;
			
			if(firstElementRating < secondElementRating)
				return NSOrderedDescending;
			else if(firstElementRating > secondElementRating)
				return NSOrderedAscending;
			
			return [firstRepo.name localizedStandardCompare:secondRepo.name];
		}];
	} else {
		// Otherwise simply sort by name
		repos =  [repos sortedArrayUsingComparator:^NSComparisonResult(StashRepo *firstRepo, StashRepo *secondRepo) {
			if(![firstRepo isKindOfClass:[StashRepo class]] || ![secondRepo isKindOfClass:[StashRepo class]]) {
				qLog(@"Unexpected object types in comparison: %@ - %@. Expecting StashRepo's", firstRepo, secondRepo);
				return NSOrderedSame;
			}
			
			return [firstRepo.name localizedStandardCompare:secondRepo.name];
		}];
	}
	
	return repos;
}


#pragma mark - 


- (BOOL)handleKeyEvent:(NSEvent *)keyEvent
{
	NSString *key = [NSString stringForKeyCode:keyEvent.keyCode withModifierFlags:keyEvent.modifierFlags];
	
	if(!key)
		return FALSE;
	
	
	BOOL hasFilterString = self.filterString.length > 0;
	BOOL foundMatch = hasFilterString;
	
	if([key isEqualToString:@"Enter"]) {
		// Switch to the issues screen
		if(hasFilterString && self.reposTableView.selectedRow >= 0) {
			[self switchToIssuesView:TRUE];
		}
	} else if([key isEqualToString:@"Escape"]) {
		// Clear the filter string
		if(hasFilterString) {
			self.filterString = nil;
		}
	} else if([key isEqualToString:@"Backspace"]) {
		// Remove the last filter string
		if(hasFilterString) {
			NSString *filterString = self.filterString;
			filterString = [filterString substringWithRange:NSMakeRange(0, filterString.length - 1)];
			self.filterString = filterString;
		}
	} else if([key isEqualToString:@"Up"] || [key isEqualToString:@"Down"]) {
		NSInteger currentSelectedRow = [self.reposTableView.selectedRowIndexes firstIndex];
		
		if(currentSelectedRow != NSNotFound) {
			if([key isEqualToString:@"Down"])
				currentSelectedRow++;
			
			if([key isEqualToString:@"Up"])
				currentSelectedRow--;
			
			NSInteger rowToSelect = MIN(MAX(0, currentSelectedRow), self.repos.count - 1);
			NSTableView *reposTableView = self.reposTableView;
			[reposTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowToSelect] byExtendingSelection:FALSE];
			[reposTableView scrollRowToVisible:rowToSelect];
		}
	} else if([key length] == 1) {
		self.filterString = [self.filterString ? : @"" stringByAppendingString:key];
	} else {
		qLog(@"Unmatched key press: %@", key);
		foundMatch = FALSE;
	}
	
	return foundMatch;
}




#pragma mark -


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.repos.count;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	StashRepoTableCellView *view = [tableView makeViewWithIdentifier:StashRepoTableCellViewIdentifier owner:self];
	
	if(!view) {
		view = [[StashRepoTableCellView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 120.0, tableView.rowHeight)];
		view.identifier = StashRepoTableCellViewIdentifier;
	}
	
	
 	StashRepo *repo = [self.repos objectAtUntestedIndex:row];
	view.textField.stringValue = repo.name;
	
	NSInteger numberOfIssues = repo.issues.count;
	view.numberLabel.stringValue = numberOfIssues > 0 ? [NSString stringWithFormat:@"%ld", numberOfIssues] : @"";
	
	NSString *iconName = repo.publicValue ? @"Public Repo" : @"Private Repo";
	view.imageView.image = [NSImage imageNamed:iconName];
	
	return view;
}



- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSIndexSet *selectedRowIndexes = self.reposTableView.selectedRowIndexes;
	
	if([selectedRowIndexes count]) {
		NSInteger selectedIndex = [selectedRowIndexes firstIndex];
		StashRepo *selectedRepo = [self.repos objectAtUntestedIndex:selectedIndex];
		
		if(selectedRepo) {
			[StashIssuesManager sharedIssuesManager].currentAccount.currentRepo = selectedRepo;
			
			NSEvent *currentEvent = [[NSApplication sharedApplication] currentEvent];
			
			if(currentEvent.type == NSLeftMouseUp) {
				[self switchToIssuesView:TRUE];
			}
		}
	}
}


- (void)switchToIssuesView:(BOOL)animated
{
	[self.popoverWindowController setRootMode:StashRootModeIssues animated:TRUE];
}



- (IBAction)logout:(id)sender
{
	NSError *error = nil;
	if(![[StashNetworkManager sharedNetworkManager] removeAuthentication:&error]) {
		NSLog(@"error: %@", error);
	}
}


- (IBAction)quit:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}


@end
