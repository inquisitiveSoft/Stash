#import <Cocoa/Cocoa.h>
#import "XSWindowController.h"

typedef enum StashRootMode : NSUInteger {
	StashRootModeLogin,
	StashRootModeIssues
} StashRootMode;


@interface StashIssuesWindowController : XSWindowController

@property (readonly) StashRootMode rootMode;
- (void)setStashRootMode:(StashRootMode)rootMode animated:(BOOL)animated;




@end
