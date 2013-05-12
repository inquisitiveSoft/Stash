#import "StashDrawingFunctions.h"


NSRect StashNSEdgeInsetsInsetRect(NSRect rect, NSEdgeInsets insets)
{
	rect.origin.y += insets.top;
	rect.origin.x += insets.left;
	rect.size.height -= insets.top + insets.bottom;
	rect.size.width -= insets.left + insets.right;
	return rect;
}