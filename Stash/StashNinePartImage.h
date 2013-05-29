#import <Cocoa/Cocoa.h>


@interface StashNinePartImage : NSImage

@property (readonly, nonatomic) NSEdgeInsets capInsets;

- (NSImage *)resizableImageWithCapInsets:(NSEdgeInsets)capInsets;
- (void)drawInRect:(NSRect)rect operation:(NSCompositingOperation)compositing fraction:(CGFloat)fraction;

@end
