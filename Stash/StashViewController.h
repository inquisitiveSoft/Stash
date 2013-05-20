#import "XSViewController.h"

@class StashPopoverWindowController;


@interface StashViewController : XSViewController

- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (StashPopoverWindowController *)popoverWindowController;

@end
