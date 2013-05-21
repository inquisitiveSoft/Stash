#import "StashIssuesViewController.h"

#import "StashIssuesManager.h"
#import "StashNetworkManager.h"

#import "StashPopoverWindowController.h"

#import "StashTextView.h"
#import "StashIssueCollectionViewItem.h"
#import "StashView.h"

#import "RegexKitLite.h"

#import "NSObject+BlockObservation.h"
#import "qLog.h"


@interface StashIssuesViewController ()

@property (strong) IBOutlet NSButton *topButton;
@property (strong) IBOutlet StashTextView *filterTextView;
@property (strong) IBOutlet NSLayoutConstraint *filterTextViewHeightConstraint;

@property (strong) IBOutlet NSScrollView *issuesCollectionScrollView;
@property (strong) IBOutlet NSCollectionView *issuesCollectionView;

@property (assign, nonatomic) StashIssuesViewMode issuesViewMode;
@property (strong) NSMutableArray *observationTokens;

@end


@implementation StashIssuesViewController


- (void)awakeFromNib
{
	[self.topButton bind:@"title" toObject:[StashIssuesManager sharedIssuesManager] withKeyPath:@"currentAccount.currentRepo.name" options:nil];
	
	StashTextView *filterTextView = self.filterTextView;
	filterTextView.delegate = self;
	filterTextView.font = [NSFont fontWithName:@"Lucida Grande" size:13.0];
	
	NSScrollView *issuesCollectionScrollView = self.issuesCollectionScrollView;
	[issuesCollectionScrollView setBackgroundColor:[NSColor clearColor]];
	[issuesCollectionScrollView setScrollerStyle:NSScrollerStyleOverlay];
	
	NSCollectionView *issuesCollectionView = self.issuesCollectionView;
	issuesCollectionView.delegate = self;
	
	StashIssueCollectionViewItem *issuesCollectionItemView = [[StashIssueCollectionViewItem alloc] initWithNibName:@"Issue Collection View Item" bundle:nil];
	[issuesCollectionView setItemPrototype:issuesCollectionItemView];
	[issuesCollectionView setMaxNumberOfColumns:1];
	[issuesCollectionView setSelectable:TRUE];
	[issuesCollectionView setMaxItemSize:NSMakeSize(1024.0, 28.0)];
	[issuesCollectionView setValue:@(FALSE) forKey:@"_animationDuration"];
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
}


- (void)updateConstraints
{
	CGFloat textViewHeight = 24.0;
	
	if(self.issuesViewMode > StashIssuesViewModeFiltering) {
		StashTextView *filterTextView = self.filterTextView;
		NSLayoutManager *layoutManager = filterTextView.layoutManager;
		NSTextContainer *textContainer = filterTextView.textContainer;
		NSRange textRange = NSMakeRange(0, filterTextView.string.length);
		
		NSRect frame = [layoutManager boundingRectForGlyphRange:textRange inTextContainer:textContainer];
		textViewHeight = MIN(frame.size.height, 88.0);
	}
	
	[self.filterTextViewHeightConstraint setConstant:textViewHeight];
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
	
	NSArray *allRepos = [issueManager fetchObjectsOfEntityName:[StashIssue entityName] matching:predicateFormat argumentArray:arguments sortDescriptors:nil];
	
	allRepos = [allRepos sortedArrayUsingComparator:^NSComparisonResult(id firstObject, id secondObject) {
		StashIssue *firstIssue = firstObject;
		StashIssue *secondIssue = secondObject;
		
		return [firstIssue.title compare:secondIssue.title options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch];
	}];
	
	self.issuesCollectionView.content = allRepos;
}


- (IBAction)switchToAccountView:(id)sender {
	[self.popoverWindowController setRootMode:StashRootModeAccount animated:TRUE];
}


- (IBAction)loadIssues:(id)sender {
	[[StashNetworkManager sharedNetworkManager] performSync];
}


#pragma mark - Text View Delegate methods


- (void)textDidChange:(NSNotification *)notification
{
	NSString *filterText = self.filterTextView.string;

	NSRange rangeOfInitialNewline = [filterText rangeOfRegex:@"^[\n\r]+"];
	if(rangeOfInitialNewline.location != NSNotFound) {
		self.filterTextView.string = [filterText substringFromIndex:rangeOfInitialNewline.length];
		[self.filterTextView setSelectedRange:NSMakeRange(0, 0)];
		
		[self setIssuesViewMode:StashIssuesViewModeFiltering];
	}
	
	if([filterText isMatchedByRegex:@"[\n\r]"]) {
		[self setIssuesViewMode:StashIssuesViewModeCreation];
	} else
		[self setIssuesViewMode:StashIssuesViewModeFiltering];
	
	[self updateConstraints];
}



@end


