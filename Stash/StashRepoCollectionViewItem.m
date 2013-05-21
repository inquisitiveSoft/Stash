#import "StashRepoCollectionViewItem.h"

#import "StashRepo.h"
#import "StashView.h"
#import "StashCollectionViewDelegate.h"


@interface StashRepoCollectionViewItem ()

@property (strong) IBOutlet NSTextField *label;
@property (strong) IBOutlet NSButton *backgroundButton;

@end



@implementation StashRepoCollectionViewItem


- (void)awakeFromNib
{
	self.label.font = [NSFont fontWithName:@"Lucida Grande" size:14.0];
	
	[self updateFields];
}


- (void)setRepresentedObject:(id)representedObject;
{
	super.representedObject = representedObject;
	[self updateFields];
}


- (void)updateFields
{
	StashRepo *repo = self.representedObject;
	
	if([repo isKindOfClass:[StashRepo class]])
		self.label.stringValue = repo.name ? : @"< Repo Name >";
}


- (IBAction)handleTap:(id)sender
{
	NSCollectionView *collectionView = self.collectionView;
	id <StashCollectionViewDelegate> delegate = (id <StashCollectionViewDelegate>)collectionView.delegate;
	
	if([delegate respondsToSelector:@selector(collectionView:didTapItem:)])
		[delegate collectionView:collectionView didTapItem:self];
}


@end
