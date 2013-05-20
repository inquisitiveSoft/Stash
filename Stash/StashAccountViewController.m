#import "StashAccountViewController.h"

#import "StashIssuesManager.h"
#import "StashNetworkManager.h"

#import "StashPopoverWindowController.h"
#import "StashRepoCollectionViewItem.h"
#import "StashView.h"

#import "NSObject+BlockObservation.h"
#import "NSArray+UntestedIndex.h"
#import "qLog.h"


@interface StashAccountViewController ()

@property (strong) NSArrayController *reposArrayController;

@property (strong) IBOutlet NSScrollView *reposCollectionScrollView;
@property (strong) IBOutlet NSCollectionView *reposCollectionView;
@property (strong) IBOutlet StashView *sideBarView;

@property (strong) NSMutableArray *observationTokens;

@end


@implementation StashAccountViewController


- (void)awakeFromNib
{
	self.sideBarView.backgroundColor = [NSColor colorWithDeviceHue:0.595 saturation:0.059 brightness:0.937 alpha:1.0];
	
	NSColor *backgroundColor = [NSColor whiteColor];
	NSScrollView *reposCollectionScrollView = self.reposCollectionScrollView;
	[reposCollectionScrollView setBackgroundColor:backgroundColor];
	[reposCollectionScrollView setScrollerStyle:NSScrollerStyleOverlay];
	
	NSCollectionView *reposCollectionView = self.reposCollectionView;
	
	StashRepoCollectionViewItem *repoCollectionItemView = [[StashRepoCollectionViewItem alloc] initWithNibName:@"Repo Collection View Item" bundle:nil];
	[reposCollectionView setItemPrototype:repoCollectionItemView];
	[reposCollectionView setMaxNumberOfColumns:1];
	[reposCollectionView setSelectable:TRUE];
	[reposCollectionView setAllowsMultipleSelection:FALSE];
	
	[reposCollectionView setBackgroundColors:@[backgroundColor]];
	[reposCollectionView setMaxItemSize:NSMakeSize(1024.0, 36.0)];
	
	NSArrayController *reposArrayController = [[NSArrayController alloc] init];
	[reposArrayController setManagedObjectContext:[[StashIssuesManager sharedIssuesManager] mainManagedObjectContext]];
	[reposArrayController setEntityName:[StashRepo entityName]];	
	[reposArrayController setAutomaticallyPreparesContent:TRUE];
	[reposArrayController setAutomaticallyRearrangesObjects:TRUE];
	[reposArrayController setFetchPredicate:nil];
	[reposArrayController setSortDescriptors:@[
		[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE]
	]];
	
	self.reposArrayController = reposArrayController;
	
	[reposCollectionView bind:NSContentBinding toObject:reposArrayController withKeyPath:@"arrangedObjects" options:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
	[self updateContent];
	
	NSMutableArray *observationTokens = [self observationTokens] ? : [[NSMutableArray alloc] init];
	__weak StashAccountViewController *accountViewController = self;
	
	id token = [[StashIssuesManager sharedIssuesManager] sk_observeKeyPath:@"currentAccount.currentRepo" change:^(id observedObject, NSString *keyPath, id oldValue, id newValue) {
		[accountViewController updateContent];
	}];
	
	if(token)
		[observationTokens addObject:token];
}


- (void)updateContent
{
//	self.view
}


- (void)viewWillDisappear:(BOOL)animated
{
	for(id observationToken in self.observationTokens)
		[NSObject sk_removeObservationForToken:observationToken];
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
