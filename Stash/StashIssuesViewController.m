#import "StashIssuesViewController.h"

#import "StashIssuesManager.h"
#import "StashNetworkManager.h"

#import "StashPopoverWindowController.h"

#import "StashTextView.h"
#import "StashIssuesTableCellView.h"
#import "StashView.h"

#import "RegexKitLite.h"

#import "NSView+ConstraintAdditions.h"
#import "NSObject+BlockObservation.h"
#import "NSString+Additions.h"
#import "NSString+ScoreForAbbreviation.h"
#import "NSArray+UntestedIndex.h"
#import "StashDrawingFunctions.h"
#import "qLog.h"


NSString * const StashIssuesTableCellViewIdentifier = @"StashIssuesTableCellViewIdentifier";


@interface StashIssuesViewController ()

@property (strong) IBOutlet NSButton *topButton;
@property (strong) IBOutlet NSButton *propertiesButton;

@property (strong) IBOutlet NSButton *filterButton;
@property (strong) IBOutlet NSButton *createButton;

@property (strong) IBOutlet StashTextView *filterTextView;
@property (strong) IBOutlet NSLayoutConstraint *filterTextViewHeightConstraint;
@property (strong) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (strong) IBOutlet NSScrollView *issuesCollectionScrollView;
@property (strong) IBOutlet NSTableView *issuesTableView;

@property (strong) NSArray *issues;
@property (assign, nonatomic) StashIssuesViewMode issuesViewMode;
@property (strong) NSMutableArray *observationTokens;

@end


@implementation StashIssuesViewController


- (void)awakeFromNib
{
	[self.topButton bind:@"title" toObject:[StashIssuesManager sharedIssuesManager] withKeyPath:@"currentAccount.currentRepo.name" options:nil];
	
	StashTextView *filterTextView = self.filterTextView;
	filterTextView.delegate = self;
	filterTextView.font = [NSFont fontWithName:@"Avenir Next Medium" size:13.0];
	
	NSScrollView *issuesCollectionScrollView = self.issuesCollectionScrollView;
	[issuesCollectionScrollView setBackgroundColor:[NSColor clearColor]];
	[issuesCollectionScrollView setScrollerStyle:NSScrollerStyleOverlay];
	
	NSTableView *issuesTableView = self.issuesTableView;
	issuesTableView.delegate = self;
	issuesTableView.dataSource = self;
	issuesTableView.rowHeight = 21.0;
	
	[self.topButton setBordered:FALSE];
	
	[self.filterButton setBordered:FALSE];
	self.filterButton.image = [NSImage imageNamed:@"Filter Button"];
	
	[self.createButton setBordered:FALSE];
	self.createButton.image = [NSImage imageNamed:@"Create Button"];
	
	[self.propertiesButton setBordered:FALSE];
	self.propertiesButton.image = [NSImage imageNamed:@"Settings Button"];
	
	// 	Will call -updateConstraints and redraw the view
	[self setIssuesViewMode:StashIssuesViewModeFiltering];
}


- (void)viewWillAppear:(BOOL)animated
{
	NSMutableArray *observationTokens = [self observationTokens] ? : [[NSMutableArray alloc] init];
	__weak StashIssuesViewController *issuesViewController = self;
	
	id token = [[StashIssuesManager sharedIssuesManager] sk_observeKeyPath:@"currentAccount.currentRepo.issues" change:^(id observedObject, NSString *keyPath, id oldValue, id newValue) {
		[issuesViewController updateIssuesList];
	}];
	
	if(token)
		[observationTokens addObject:token];
	
	[self updateIssuesList];
	[self updateConstraints];
}


- (void)viewDidAppear:(BOOL)animated
{
	[self.view.window makeFirstResponder:self.filterTextView];
}



- (void)viewWillDisappear:(BOOL)animated
{
	for(id observationToken in self.observationTokens)
		[NSObject sk_removeObservationForToken:observationToken];
}


- (void)setIssuesViewMode:(StashIssuesViewMode)issuesViewMode
{
	self.filterTextView.scrollEnabled = !(issuesViewMode == StashIssuesViewModeFiltering);
	_issuesViewMode = issuesViewMode;
	
	[self updateConstraints];
	[self updateDrawing];
}


- (void)updateConstraints
{
	CGFloat minimumTextViewHeight = 23.0;
	CGFloat maximumTextViewHeight = 77.0;
	CGFloat textViewHeight = minimumTextViewHeight;
	CGFloat tableViewTopPosition = 49;
	
	if(self.issuesViewMode > StashIssuesViewModeFiltering) {
		StashTextView *filterTextView = self.filterTextView;
		NSTextContainer *textContainer = filterTextView.textContainer;
		NSLayoutManager *layoutManager = filterTextView.layoutManager;
		
		(void)[layoutManager glyphRangeForTextContainer:textContainer];		// Performs the layout
		textViewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
		textViewHeight = MAX(minimumTextViewHeight, MIN(textViewHeight, maximumTextViewHeight));
		
		tableViewTopPosition += 22.0;
	}
	
	tableViewTopPosition += textViewHeight;
	
	[self.filterTextViewHeightConstraint setConstant:textViewHeight];
	[self.tableViewTopConstraint setConstant:tableViewTopPosition];
}


- (void)updateDrawing
{
	__weak StashIssuesViewController *issuesViewController = self;
	
	[(StashView *)self.view setDrawBlock:^(StashView *view, NSRect dirtyRect) {
		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		
		// Draw the background
		CGContextSetFillColorWithColor(context, [[NSColor colorWithDeviceHue:0.529 saturation:0.057 brightness:0.55 alpha:1.000] CGColor]);
		CGContextFillRect(context, dirtyRect);
		
		CGFloat tableViewTopPosition = self.tableViewTopConstraint.constant;
		CGRect rect = view.bounds;
		rect.size.height -= issuesViewController.topButton.frame.size.height;
		
		CGPathRef roundedPath = createCGPathForRoundedRect(rect, 3.0);
		CGContextAddPath(context, roundedPath);
		CGPathRelease(roundedPath);
		
		CGContextSetFillColorWithColor(context, [[NSColor colorWithDeviceHue:0.529 saturation:0.057 brightness:0.7 alpha:1.000] CGColor]);
		CGContextFillPath(context);
		
		
		rect = view.bounds;
		rect.size.height -= tableViewTopPosition;
		
		roundedPath = createCGPathForRoundedRect(CGRectIntegral(rect), 3.0);
		CGContextAddPath(context, roundedPath);
		CGPathRelease(roundedPath);
		
		CGContextSetFillColorWithColor(context, [[NSColor colorWithDeviceHue:0.529 saturation:0.057 brightness:0.879 alpha:1.000] CGColor]);
		CGContextFillPath(context);
		
//		CGContextSetFillColorWithColor(context, [[NSColor colorWithDeviceHue:0.529 saturation:0.057 brightness:0.55 alpha:1.000] CGColor]);
//		CGContextFillRect(context, CGRectMake(0.0, rect.size.height + 19.0, rect.size.width, 1.0));
	}];
	
	[self.view setNeedsDisplay:TRUE];
}



- (void)updateFilterField:(id)sender
{
	[self updateIssuesList];
}


- (void)updateIssuesList
{
	StashIssuesManager *issueManager = [StashIssuesManager sharedIssuesManager];
	NSMutableArray *arguments = [[NSMutableArray alloc] init];
	NSMutableString *predicateFormat = [[NSMutableString alloc] init];
	
	StashRepo *currentRepo = issueManager.currentAccount.currentRepo;
	if(currentRepo) {
		[predicateFormat appendString:@"repo == %@"];
		[arguments addObject:currentRepo];
	}
	
	NSString *filterString = self.filterTextView.string;
	if([filterString length]) {
		if([predicateFormat length] > 0)
			[predicateFormat appendString:@" AND "];
		
		[predicateFormat appendString:@"title == %@"];
		[arguments addObject:filterString];
	}
	
	NSArray *issues = [issueManager fetchObjectsOfEntityName:[StashIssue entityName] matching:predicateFormat argumentArray:arguments sortDescriptors:@[
		[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:FALSE]
	]];
	
	self.issues = issues;
	[self.issuesTableView reloadData];
}


- (NSArray *)sortedArrayOfIssues:(NSArray *)issues usingAbbreviation:(NSString *)abbreviation
{
	if([abbreviation length]) {
		// Sort by the abbreviation score
		for(StashIssue *issue in issues) {
			// Happily clobber any existing scoreForAbbreviation or maskForAbbreviation
			NSMutableIndexSet *mask = [[NSMutableIndexSet alloc] init];
			issue.scoreForAbbreviation = [[issue.title normalizedString] scoreForAbbreviation:abbreviation hitMask:&mask];
			issue.maskForAbbreviation = [mask copy];
		}
		
		issues = [issues sortedArrayUsingComparator:^NSComparisonResult(StashIssue *firstIssue, StashIssue *secondIssue) {
			//
			if(![firstIssue isKindOfClass:[StashIssue class]] || ![secondIssue isKindOfClass:[StashIssue class]]) {
				qLog(@"Unexpected object types in comparison: %@ - %@. Expecting StashIssue's", firstIssue, secondIssue);
				return NSOrderedSame;
			}
			
			CGFloat firstElementRating = firstIssue.scoreForAbbreviation;
			CGFloat secondElementRating = secondIssue.scoreForAbbreviation;
			
			if(firstElementRating < secondElementRating)
				return NSOrderedDescending;
			else if(firstElementRating > secondElementRating)
				return NSOrderedAscending;
			
			return [firstIssue.title localizedStandardCompare:secondIssue.title];
		}];
	} else {
		// Otherwise simply sort by name
		issues =  [issues sortedArrayUsingComparator:^NSComparisonResult(StashIssue *firstIssue, StashIssue *secondIssue) {
			if(![firstIssue isKindOfClass:[StashIssue class]] || ![secondIssue isKindOfClass:[StashIssue class]]) {
				qLog(@"Unexpected object types in comparison: %@ - %@. Expecting StashIssue's", firstIssue, secondIssue);
				return NSOrderedSame;
			}
			
			return [firstIssue.title localizedStandardCompare:secondIssue.title];
		}];
	}
	
	return issues;
}



- (IBAction)switchToAccountView:(id)sender {
	[self.popoverWindowController setRootMode:StashRootModeAccount animated:TRUE];
}


- (IBAction)loadIssues:(id)sender {
	[[StashNetworkManager sharedNetworkManager] performSync];
}


#pragma mark - Text View Delegate methods


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.issues.count;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	__block StashIssuesTableCellView *view = [tableView makeViewWithIdentifier:StashIssuesTableCellViewIdentifier owner:self];
	
	if(!view) {
		view = [[StashIssuesTableCellView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 120.0, tableView.rowHeight)];
		view.identifier = StashIssuesTableCellViewIdentifier;
	}
	
 	view.issue = [self.issues objectAtUntestedIndex:row];
	
	return view;
}


- (void)textDidChange:(NSNotification *)notification
{
	NSString *filterText = self.filterTextView.string;

	NSRange rangeOfInitialNewline = [filterText rangeOfRegex:@"^[\n\r]+"];
	if(rangeOfInitialNewline.location != NSNotFound) {
		self.filterTextView.string = [filterText substringFromIndex:rangeOfInitialNewline.length];
		[self.filterTextView setSelectedRange:NSMakeRange(0, 0)];
		
		[self setIssuesViewMode:StashIssuesViewModeFiltering];
	}
	
	if(filterText.length > 15 || [filterText isMatchedByRegex:@"[\n\r]"]) {
		[self setIssuesViewMode:StashIssuesViewModeCreation];
	} else
		[self setIssuesViewMode:StashIssuesViewModeFiltering];
	
	[self updateConstraints];
}



@end


