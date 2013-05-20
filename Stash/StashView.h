#import <Cocoa/Cocoa.h>


@class StashView;

typedef void (^ StashViewDrawBlock)(StashView *view, NSRect dirtyRect);


@interface StashView : NSView

@property (strong, nonatomic) id representedObject;
@property (strong, nonatomic) NSColor *backgroundColor;
@property (strong, nonatomic) StashViewDrawBlock drawBlock;

@end
