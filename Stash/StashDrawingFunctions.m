#import "StashDrawingFunctions.h"


NSRect StashNSEdgeInsetsInsetRect(NSRect rect, NSEdgeInsets insets)
{
	rect.origin.y += insets.top;
	rect.origin.x += insets.left;
	rect.size.height -= insets.top + insets.bottom;
	rect.size.width -= insets.left + insets.right;
	return rect;
}


CGMutablePathRef createCGPathForRoundedRect(CGRect contentRect, CGFloat radius)
{
	CGRect innerRect = CGRectInset(contentRect, radius, radius);
	
	CGMutablePathRef roundedPath = CGPathCreateMutable();
	CGPathMoveToPoint(roundedPath, NULL, CGRectGetMinX(innerRect), CGRectGetMinY(contentRect));
	CGPathAddArcToPoint(roundedPath, NULL, CGRectGetMaxX(contentRect), CGRectGetMinY(contentRect), CGRectGetMaxX(contentRect), CGRectGetMinY(innerRect), radius);
	CGPathAddArcToPoint(roundedPath, NULL,  CGRectGetMaxX(contentRect), CGRectGetMaxY(contentRect), CGRectGetMaxX(innerRect), CGRectGetMaxY(contentRect), radius);
	CGPathAddArcToPoint(roundedPath, NULL,  CGRectGetMinX(contentRect), CGRectGetMaxY(contentRect), CGRectGetMinX(contentRect), CGRectGetMaxY(innerRect), radius);
	CGPathAddArcToPoint(roundedPath, NULL,  CGRectGetMinX(contentRect), CGRectGetMinY(contentRect), CGRectGetMinX(innerRect), CGRectGetMinY(contentRect), radius);
	CGPathCloseSubpath(roundedPath);
	
	return roundedPath;
}
