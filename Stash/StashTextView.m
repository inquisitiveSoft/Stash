#import "StashTextView.h"


@implementation StashTextView


- (void)drawInsertionPointInRect:(NSRect)rect color:(NSColor *)aColor turnedOn:(BOOL)flag
{
	[[NSColor blueColor] setFill];
	
	rect.size.width = 1.0;
	rect = NSInsetRect(rect, 0.0, 1.0);
	NSRectFill(rect);
}


- (NSRect)adjustScroll:(NSRect)proposedRect
{
	if(!self.scrollEnabled)
		proposedRect.origin = NSZeroPoint;
	
	return proposedRect;
}


@end
