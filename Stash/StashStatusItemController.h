#import <Foundation/Foundation.h>

@class StashPopoverWindowController;


@interface StashStatusItemController : NSObject

@property (weak, nonatomic) StashPopoverWindowController *popoverWindowController;

- (void)presentStatusBar;

// Manage the popover
- (BOOL)isPopoverVisible;
- (void)displayPopover;
- (void)hidePopover;

@end
