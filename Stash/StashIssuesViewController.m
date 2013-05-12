#import "StashIssuesViewController.h"
#import "StashNetworkManager.h"
#import "StashView.h"


@interface StashIssuesViewController ()

@end


@implementation StashIssuesViewController


- (void)awakeFromNib
{
	StashView *view = (StashView *)self.view;
	view.backgroundColor = [NSColor colorWithDeviceHue:0.144 saturation:0.209 brightness:0.952 alpha:1.000];
}


- (IBAction)resignAuthentication:(id)sender {
	NSError *error = nil;
	if(![[StashNetworkManager sharedNetworkManager] removeAuthentication:&error]) {
		NSLog(@"error: %@", error);
	}
}







#pragma mark - NSCollectionViewDelegate methods







@end
