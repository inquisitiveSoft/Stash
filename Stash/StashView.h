#import <Cocoa/Cocoa.h>


@class StashView;

typedef void (^ StashViewDrawBlock)(StashView *view, NSRect dirtyRect);
typedef void (^ StashKeyEventHandlingBlock)(NSEvent *keyEvent, BOOL *shouldCallSuper);

@interface StashView : NSView

@property (strong, nonatomic) id representedObject;
@property (strong, nonatomic) NSColor *backgroundColor;
@property (strong, nonatomic) StashViewDrawBlock drawBlock;
@property (strong, nonatomic) StashKeyEventHandlingBlock keyEventHandlingBlock;

@end
