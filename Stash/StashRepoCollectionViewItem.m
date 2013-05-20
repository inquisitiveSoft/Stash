#import "StashRepoCollectionViewItem.h"

#import "StashAccount.h"
#import "StashRepo.h"
#import "StashView.h"

@interface StashRepoCollectionViewItem ()

@property (strong) IBOutlet NSButton *button;

@end



@implementation StashRepoCollectionViewItem


- (void)awakeFromNib
{
	self.textField.font = [NSFont fontWithName:@"Menlo" size:12.0];
	
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
		self.button.title = repo.name ? : @"< Repo Name >";
}


- (IBAction)makeActiveRepo:(id)sender
{
	StashRepo *repo = self.representedObject;
	
	if([repo isKindOfClass:[StashRepo class]]) {
		repo.account.currentRepo = repo;
	}
}


@end
