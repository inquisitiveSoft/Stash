#import "StashViewController.h"

#import "StashPopoverWindowController.h"
#import "NSObject+BlockObservation.h"


@interface StashViewController ()

@end



@implementation StashViewController

// Stub methods to be overridden
- (void)viewWillAppear:(BOOL)animated {}
- (void)viewDidAppear:(BOOL)animated {}
- (void)viewWillDisappear:(BOOL)animated {}
- (void)viewDidDisappear:(BOOL)animated {}


- (StashPopoverWindowController *)popoverWindowController
{
	return (StashPopoverWindowController *)self.windowController;
}


@end
