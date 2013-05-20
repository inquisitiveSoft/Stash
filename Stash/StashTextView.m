#import "StashTextView.h"


@implementation StashTextView


- (void)drawInsertionPointInRect:(NSRect)aRect color:(NSColor *)aColor turnedOn:(BOOL)flag
{
	[[NSColor blueColor] setFill];
	
	aRect.size.width = 1.0;
	NSRectFill(aRect);
}


@end
