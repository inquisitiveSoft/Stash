#import "StashView.h"


@implementation StashView


- (void)setBackgroundColor:(NSColor *)backgroundColor
{
	_backgroundColor = backgroundColor;
	
	[self setNeedsDisplay:TRUE];
}


- (void)setDrawBlock:(StashViewDrawBlock)drawBlock
{
	_drawBlock = drawBlock;
	
	[self setNeedsDisplay:TRUE];
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	StashViewDrawBlock drawBlock = self.drawBlock;
	
	if(drawBlock) {
		drawBlock(self, dirtyRect);
	} else if(self.backgroundColor) {
		[self.backgroundColor ? : [NSColor yellowColor] setFill];
		NSRectFill(dirtyRect);
	}
}


@end
