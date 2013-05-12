#import <Cocoa/Cocoa.h>


@class StashViewController;


@interface StashTexturedWindow : NSWindow

@property (readonly, retain, nonatomic) StashViewController *contentViewController;
- (void)setContentViewController:(StashViewController *)destinationView animated:(BOOL)animated animationDirecton:(NSString *)animationDirection;

@end
