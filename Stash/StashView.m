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


@end
