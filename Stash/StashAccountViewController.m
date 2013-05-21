#import "StashAccountViewController.h"

#import "StashIssuesManager.h"
#import "StashNetworkManager.h"

#import "StashPopoverWindowController.h"
#import "StashRepoCollectionViewItem.h"
#import "StashView.h"

#import <QuartzCore/QuartzCore.h>

#import "NSObject+BlockObservation.h"
#import "NSArray+UntestedIndex.h"
#import "NSString+Additions.h"
#import "NSString+ScoreForAbbreviation.h"
#import "qLog.h"


@interface StashAccountViewController ()

@property (strong) IBOutlet NSScrollView *reposCollectionScrollView;
@property (strong) IBOutlet NSCollectionView *reposCollectionView;
@property (strong) IBOutlet NSSearchField *filterField;
@property (strong) IBOutlet StashView *filterBackgroundView;

@property (strong) IBOutlet NSTextField *usernameField;
@property (strong) IBOutlet NSTextField *fullNameField;

@property (strong) NSArray *currentRepos;
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
	
	NSCollectionView *reposCollectionView = self.reposCollectionView;
	
	StashRepoCollectionViewItem *repoCollectionItemView = [[StashRepoCollectionViewItem alloc] initWithNibName:@"Repo Collection View Item" bundle:nil];
	reposCollectionView.delegate = self;
	reposCollectionView.itemPrototype = repoCollectionItemView;
	reposCollectionView.maxNumberOfColumns = 1;
	reposCollectionView.maxItemSize = NSMakeSize(1024.0, 36.0);
	
	[self.usernameField bind:@"stringValue" toObject:[StashIssuesManager sharedIssuesManager] withKeyPath:@"currentAccount.username" options:nil];
	[self.fullNameField	bind:@"stringValue" toObject:[StashIssuesManager sharedIssuesManager] withKeyPath:@"currentAccount.name" options:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
	[self updateContent];
	
	NSMutableArray *observationTokens = [self observationTokens] ? : [[NSMutableArray alloc] init];
	__weak StashAccountViewController *accountViewController = self;
	
	id token = [[StashIssuesManager sharedIssuesManager] sk_observeKeyPath:@"currentAccount.repos" change:^(id observedObject, NSString *keyPath, id oldValue, id newValue) {
		[accountViewController updateContent];
	}];
	
	if(token)
		[observationTokens addObject:token];
}


- (void)viewWillDisappear:(BOOL)animated
{
	for(id observationToken in self.observationTokens)
		[NSObject sk_removeObservationForToken:observationToken];
}


- (void)updateContent
{
	NSString *filterString = self.filterField.stringValue;
	
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
	
	
	NSArray *allRepos = [[StashIssuesManager sharedIssuesManager] fetchObjectsOfEntityName:[StashRepo entityName] matching:predicateFormat argumentArray:arguments sortDescriptors:nil];
	allRepos = [self sortedArrayOfRepos:allRepos usingAbbreviation:filterString];
	
	self.currentRepos = allRepos;
	self.reposCollectionView.content = allRepos;
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

- (void)controlTextDidChange:(NSNotification *)notification
{
	[self updateContent];
}


- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	StashRepo *repo = (StashRepo *)[self.currentRepos objectAtUntestedIndex:0];
	[StashIssuesManager sharedIssuesManager].currentAccount.currentRepo = repo;
	return TRUE;
}



#pragma mark -

- (void)collectionView:(id)collectionView didTapItem:(NSCollectionViewItem *)item
{
	StashRepo *repo = item.representedObject;
	
	if([repo isKindOfClass:[StashRepo class]]) {
		repo.account.currentRepo = repo;
		[self.popoverWindowController setRootMode:StashRootModeIssues animated:TRUE];
	}
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
