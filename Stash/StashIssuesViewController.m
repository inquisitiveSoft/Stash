#import "StashIssuesViewController.h"
#import "StashNetworkManager.h"
#import "StashView.h"


@interface StashIssuesViewController ()

@end


@implementation StashIssuesViewController


- (void)awakeFromNib
{
//	StashView *view = (StashView *)self.view;
}


- (IBAction)resignAuthentication:(id)sender {
	NSError *error = nil;
	if(![[StashNetworkManager sharedNetworkManager] removeAuthentication:&error]) {
		NSLog(@"error: %@", error);
	}
}







#pragma mark - NSCollectionViewDelegate methods







@end
