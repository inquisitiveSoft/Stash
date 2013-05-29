#import "StashIssuesViewController.h"

#import "StashIssuesManager.h"
#import "StashNetworkManager.h"

#import "StashPopoverWindowController.h"

#import "StashTextView.h"
#import "StashIssuesTableCellView.h"
#import "StashButton.h"
#import "StashView.h"
#import "StashTableRowView.h"

#import "RegexKitLite.h"

#import "NSView+ConstraintAdditions.h"
#import "NSObject+BlockObservation.h"
#import "NSString+Additions.h"
#import "NSString+ScoreForAbbreviation.h"
#import "NSArray+UntestedIndex.h"

#import "StashNinePartImage.h"
#import "StashDrawingFunctions.h"
#import "qLog.h"


NSString * const StashIssuesTableCellViewIdentifier = @"StashIssuesTableCellViewIdentifier";

NSString * const StashIssuesFilterIssueNumberRegex = @"(?<!\\\\)#:?(\\d+)?( |$)";
NSString * const StashIssuesFilterLabelKey = @"StashIssuesFilterLabelKey";

NSString * const StashIssuesFilterLabelRegex = @"(l|label):[ \\t]{0,3}(.+)";
NSString * const StashIssuesFilterMilestoneRegex = @"(m|milestone):[ \\t]{0,3}(.+)";

@interface StashIssuesViewController ()


@property (strong) IBOutlet NSString *filterString;

@property (strong) IBOutlet StashButton *topButton;
@property (strong) IBOutlet StashButton *propertiesButton;

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

@property (strong) NSRegularExpression *issueNumberRegex, *labelRegex, *milestoneRegex;



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
	issuesTableView.rowHeight = 22.0;
	issuesTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
	
	NSImage *backgroundImage = [[StashNinePartImage imageNamed:@"Top Button Normal"] resizableImageWithCapInsets:NSEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];	
	
	self.topButton.font = [NSFont fontWithName:@"Avenir Next Medium" size:14.0];
	self.topButton.backgroundImage = backgroundImage;
	[self.topButton setTitleShadowColor:[NSColor whiteColor] forState:StashButtonStateNormal];
	
	self.propertiesButton.backgroundImage = backgroundImage;
	
	[self.filterButton setBordered:FALSE];
	self.filterButton.image = [NSImage imageNamed:@"Filter Button"];
	
	[self.createButton setBordered:FALSE];
	self.createButton.image = [NSImage imageNamed:@"Create Button"];

	
	self.issueNumberRegex = [NSRegularExpression regularExpressionWithPattern:StashIssuesFilterIssueNumberRegex options:NSRegularExpressionCaseInsensitive error:NULL];
	self.labelRegex = [NSRegularExpression regularExpressionWithPattern:StashIssuesFilterLabelRegex options:NSRegularExpressionCaseInsensitive error:NULL];
	self.milestoneRegex = [NSRegularExpression regularExpressionWithPattern:StashIssuesFilterMilestoneRegex options:NSRegularExpressionCaseInsensitive error:NULL];
	
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
	CGFloat tableViewTopPosition = 50;
	
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
	
	[(StashView *)self.view setDrawBlock:^(NSView *view, NSRect dirtyRect) {
		NSRect bounds = view.bounds;
		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGFloat tableViewTopPosition = self.tableViewTopConstraint.constant;
		
		// Draw the background under the table view
		CGContextSetFillColorWithColor(context, [[NSColor whiteColor] CGColor]);
		CGContextFillRect(context, dirtyRect);
		
		
		// Clip the filter fields gradient
		CGContextSaveGState(context);
		CGRect rect = bounds;
		rect.size.height -= tableViewTopPosition;
		
		CGPathRef roundedPath = createCGPathForRoundedRect(rect, 3.0);
		CGContextAddRect(context, NSRectToCGRect(bounds));
		CGContextAddPath(context, roundedPath);
		CGContextEOClip(context);
		
		// Draw the filter fields gradient
		NSColor *firstColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.93 alpha:1.000];
		NSColor *secondColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.95 alpha:1.000];
		NSColor *thirdColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.97 alpha:1.000];
		
		NSArray *colors = @[
			(__bridge_transfer id)[firstColor CGColor],
			(__bridge_transfer id)[secondColor CGColor],
			(__bridge_transfer id)[thirdColor CGColor],
		];
		
		CGFloat locations[3];
		locations[0] = 0.0;
		locations[1] = 0.25;
		locations[2] = 1.0;
		
		CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge_retained CFArrayRef)colors, locations);
		CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, bounds.size.height - 40.0), CGPointMake(0.0, bounds.size.height - tableViewTopPosition - 5.0), 0);
		CGGradientRelease(gradient);
		
		CGContextAddPath(context, roundedPath);
		CGContextSetStrokeColorWithColor(context, [[NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.85 alpha:1.000] CGColor]);
		CGContextStrokePath(context);

		CGPathRelease(roundedPath);
		roundedPath = nil;
		
		CGContextRestoreGState(context);
		
		
		rect = bounds;
		rect.size.height -= 42.0;
		
		// Clip the top gradient
		CGContextSaveGState(context);
		roundedPath = createCGPathForRoundedRect(rect, 3.0);
		CGContextAddRect(context, NSRectToCGRect(bounds));
		CGContextAddPath(context, roundedPath);
		CGContextEOClip(context);
		
		// Draw the top gradient
		firstColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.921 alpha:1.000];
		secondColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.9 alpha:1.000];
		thirdColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.91 alpha:1.000];
		
		colors = @[
			(__bridge_transfer id)[firstColor CGColor],
			(__bridge_transfer id)[secondColor CGColor],
			(__bridge_transfer id)[thirdColor CGColor],
		];
		
		locations[0] = 0.0;
		locations[1] = 0.55;
		locations[2] = 1.0;
		
		gradient = CGGradientCreateWithColors(colorSpace, (__bridge_retained CFArrayRef)colors, locations);
		CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, bounds.size.height), CGPointMake(0.0, bounds.size.height - 52.0), 0);
		CGGradientRelease(gradient);
		
		CGContextAddPath(context, roundedPath);
		CGPathRelease(roundedPath);
		
		CGContextSetStrokeColorWithColor(context, [[NSColor lightGrayColor] CGColor]);
		CGContextStrokePath(context);
		CGContextRestoreGState(context);		
		CGColorSpaceRelease(colorSpace);
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
	
	
	NSMutableString *filterString = [self.filterString mutableCopy];
	
	[self parseIssueNumbersFromFilterString:&filterString intoPredicateFormat:&predicateFormat andArgumentsArray:&arguments];
	NSString *abbreviation = [self parseFuzzyRegexFromFilterString:&filterString intoPredicateFormat:&predicateFormat andArgumentsArray:&arguments];
	
	NSArray *issues = [issueManager fetchObjectsOfEntityName:[StashIssue entityName] matching:predicateFormat argumentArray:arguments sortDescriptors:@[
		[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:FALSE]
	]];
	
	issues = [self sortedArrayOfIssues:issues usingAbbreviation:abbreviation];
	
	self.issues = issues;
	[self.issuesTableView reloadData];
}


#pragma mark - Filter String Parsing


- (BOOL)parseIssueNumbersFromFilterString:(NSMutableString **)filterString intoPredicateFormat:(NSMutableString **)predicateFormat andArgumentsArray:(NSMutableArray **)arguments
{
	if(filterString == NULL || [*filterString length] == 0 || predicateFormat == NULL || arguments == NULL)
		return FALSE;
	
	// Filter Issue Numbers
	NSTextCheckingResult *issueNumberMatch = [self.issueNumberRegex firstMatchInString:*filterString options:0 range:NSMakeRange(0, [*filterString length])];
	NSNumber *issueNumber = nil;
	
	if(issueNumberMatch) {
		if(issueNumberMatch.numberOfRanges >= 2) {
			NSRange rangeOfCapture = [issueNumberMatch rangeAtIndex:1];
			
			if(rangeOfCapture.length > 0) {
				if([*predicateFormat length] > 0)
					[*predicateFormat appendString:@" AND "];
				
				[*predicateFormat appendString:@"number = %@"];
				
				NSString *issueNumberString = [*filterString substringWithRange:rangeOfCapture];
				issueNumber = @([issueNumberString integerValue]);
				
				[*arguments addObject:issueNumber];
			}
		}
		
		[*filterString deleteCharactersInRange:issueNumberMatch.range];
	}
	
	[self trimWhitespaceFromMutableString:filterString];
	return (BOOL)issueNumber;
}



- (NSString *)parseFuzzyRegexFromFilterString:(NSMutableString **)filter intoPredicateFormat:(NSMutableString **)predicateFormat andArgumentsArray:(NSMutableArray **)arguments
{
	NSString *abbreviation = nil;
	
	if(filter != NULL && predicateFormat != NULL && arguments != NULL && [*filter length] > 0) {
		NSMutableString *filterString = *filter;
	
		if([*predicateFormat length] > 0)
			[*predicateFormat appendString:@" AND "];
		
		// Match the remainder as a regex
		__block NSMutableString *abbreviationMatchingRegex = [[NSMutableString alloc] initWithString:@".*"];
		__block NSCharacterSet *regularExpressionCharactersToEscape = [NSCharacterSet characterSetWithCharactersInString:@".+*?[^]$(){}=!<>|:-"];
		
		[filterString enumerateSubstringsInRange:NSMakeRange(0, [filterString length])
														 options:NSStringEnumerationByComposedCharacterSequences
													  usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			if([substring rangeOfCharacterFromSet:regularExpressionCharactersToEscape].location != NSNotFound)
				[abbreviationMatchingRegex appendString:@"\\"];
			
			[abbreviationMatchingRegex appendString:substring];
			[abbreviationMatchingRegex appendString:@".*"];
		}];
		
		[*predicateFormat appendString:@"title MATCHES[cd] %@"];
		[*arguments addObject:abbreviationMatchingRegex];
		abbreviation = [filterString copy];
		
		[*filter setString:@""];
	}
	
	return abbreviation;
}


- (void)trimWhitespaceFromMutableString:(NSMutableString **)filterString
{
	if(filterString != NULL && [*filterString length]) {
		NSRange rangeOfLeadingWhitespace = [*filterString rangeOfRegex:@"^\\s+"];
		if(rangeOfLeadingWhitespace.location != NSNotFound)
			[*filterString deleteCharactersInRange:rangeOfLeadingWhitespace];

		NSRange rangeOfTrailingWhitespace = [*filterString rangeOfRegex:@"\\s+$"];
		if(rangeOfTrailingWhitespace.location != NSNotFound)
			[*filterString deleteCharactersInRange:rangeOfTrailingWhitespace];
	}
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
		// Otherwise simply sort by issue number and then name
		issues = [issues sortedArrayUsingDescriptors:@[
			[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:FALSE],
			[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:FALSE]
		]];
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


- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
	return [[StashTableRowView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 120.0, 17.0)];
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
	
	self.filterString = self.filterTextView.string;
	[self updateIssuesList];
}



@end


