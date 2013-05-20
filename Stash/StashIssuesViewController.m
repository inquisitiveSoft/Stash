#import "StashIssuesViewController.h"

#import "StashIssuesManager.h"
#import "StashNetworkManager.h"

#import "StashPopoverWindowController.h"
#import "StashTopButton.h"
#import "StashTextView.h"
#import "StashIssueCollectionViewItem.h"
#import "StashView.h"

#import "qLog.h"


@interface StashIssuesViewController ()

@property (strong) IBOutlet StashIssueCollectionViewItem *collectionViewItem;
@property (strong) IBOutlet StashTopButton *topButton;

@property (strong) IBOutlet StashTextView *searchField;

@property (strong) IBOutlet NSScrollView *issuesCollectionScrollView;
@property (strong) IBOutlet NSCollectionView *issuesCollectionView;

@property (strong) IBOutlet NSArrayController *issuesArrayController;

@end


@implementation StashIssuesViewController


- (void)awakeFromNib
{
//	__weak StashIssuesViewController *issuesViewController = self;
//	
//	[[NSNotificationCenter defaultCenter] addObserverForName:StashCurrentAccountDidChange object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
////		StashAccount *currentAccount = [[StashIssuesManager sharedIssuesManager] currentAccount];
////		issuesViewController.accountButton.title = currentAccount.username ? : @"< Account Name >";
////		
////		currentAccount.currentRepo.title
////		issuesViewController.repoButton.title = nil ? : @"< Current Repo >";
//	}];

	[self.topButton bind:@"title" toObject:[StashIssuesManager sharedIssuesManager] withKeyPath:@"currentAccount.currentRepo.name" options:nil];
	
	
	NSColor *backgroundColor = [NSColor whiteColor];
	NSScrollView *issuesCollectionScrollView = self.issuesCollectionScrollView;
	[issuesCollectionScrollView setBackgroundColor:backgroundColor];
	[issuesCollectionScrollView setScrollerStyle:NSScrollerStyleOverlay];
	
	NSCollectionView *issuesCollectionView = self.issuesCollectionView;
	issuesCollectionView.delegate = self;
	
	StashIssueCollectionViewItem *issuesCollectionItemView = [[StashIssueCollectionViewItem alloc] initWithNibName:@"Issue Collection View Item" bundle:nil];
	[issuesCollectionView setItemPrototype:issuesCollectionItemView];
	[issuesCollectionView setMaxNumberOfColumns:1];
	[issuesCollectionView setSelectable:TRUE];
	[issuesCollectionView setBackgroundColors:@[backgroundColor]];
	[issuesCollectionView setMaxItemSize:NSMakeSize(1024.0, 28.0)];
	
	NSArrayController *issuesArrayController = [[NSArrayController alloc] init];
	[issuesArrayController setManagedObjectContext:[[StashIssuesManager sharedIssuesManager] mainManagedObjectContext]];
	[issuesArrayController setEntityName:[StashIssue entityName]];	
	[issuesArrayController setAutomaticallyPreparesContent:TRUE];
	[issuesArrayController setAutomaticallyRearrangesObjects:TRUE];
	[issuesArrayController setUsesLazyFetching:TRUE];
	[issuesArrayController setFetchPredicate:nil];
	
	self.issuesArrayController = issuesArrayController;
	
	[issuesCollectionView bind:NSContentBinding	toObject:issuesArrayController withKeyPath:@"arrangedObjects" options:nil];
	
	self.searchField.font = [NSFont fontWithName:@"Inconsolata" size:16.0];
}


- (void)viewDidAppear:(BOOL)animated
{
	[self.issuesArrayController fetch:nil];
}


- (IBAction)switchToAccountView:(id)sender {
	[self.popoverWindowController setRootMode:StashRootModeAccount animated:TRUE];
}


- (IBAction)loadIssues:(id)sender {
	[[StashNetworkManager sharedNetworkManager] performSync];
}




@end
