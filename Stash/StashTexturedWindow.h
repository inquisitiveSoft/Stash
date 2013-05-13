#import <Cocoa/Cocoa.h>


@class StashViewController;


@interface StashTexturedWindow : NSWindow

@property (readonly, retain, nonatomic) StashViewController *contentViewController;
@property (assign, nonatomic) CGPoint attachmentPosition;

- (void)setContentViewController:(StashViewController *)destinationView animated:(BOOL)animated animationDirecton:(NSString *)animationDirection;

@end
