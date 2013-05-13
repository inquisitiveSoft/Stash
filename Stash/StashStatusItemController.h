#import <Foundation/Foundation.h>

@class StashIssuesWindowController;


@interface StashStatusItemController : NSObject

@property (weak, nonatomic) StashIssuesWindowController *popoverWindowController;

- (void)presentStatusBar;

// Manage the popover
- (BOOL)isPopoverVisible;
- (void)displayPopover;
- (void)hidePopover;

@end
