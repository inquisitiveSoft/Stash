#import "StashTableRowView.h"
#import "StashNinePartImage.h"


@implementation StashTableRowView


- (void)drawSelectionInRect:(NSRect)dirtyRect
{
	NSRect selectionRect = NSInsetRect(self.bounds, 6.0, 1.0);
	selectionRect.origin.y += 1.0;
	
	StashNinePartImage *selectionImage = (StashNinePartImage *)[[StashNinePartImage imageNamed:@"Issues Selection"] resizableImageWithCapInsets:NSEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)];
	[selectionImage drawInRect:selectionRect operation:NSCompositeSourceOver fraction:1.0];
}


@end
