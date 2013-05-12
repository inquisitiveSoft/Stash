#import <Cocoa/Cocoa.h>
#import "XSWindowController.h"

typedef enum StashRootMode : NSUInteger {
	StashRootModeUnknown,
	StashRootModeLogin,
	StashRootModeIssues
} StashRootMode;


@interface StashIssuesWindowController : XSWindowController

@property (readonly, nonatomic) StashRootMode rootMode;
- (void)setRootMode:(StashRootMode)rootMode animated:(BOOL)animated;




@end
