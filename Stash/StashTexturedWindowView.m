#import "StashTexturedWindowView.h"
#import "StashDrawingFunctions.h"


@interface StashTexturedWindowView () {
	CGSize arrowSize;
	CGFloat cornerRadius, innerCornerRadius, contentPadding, shadowRadius;
	CGSize shadowOffset;
	NSEdgeInsets shadowInsets, contentInsets;
}

@end


@implementation StashTexturedWindowView
@synthesize innerCornerRadius = innerCornerRadius, contentInsets = contentInsets, shadowInsets = shadowInsets_;


- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self) {
		self.layer = [CALayer layer];
		self.wantsLayer = TRUE;
		
		arrowSize = CGSizeMake(22.0f, 11.0f);
		
		cornerRadius = 6.0f;
		contentPadding = 1.0f;
		innerCornerRadius = roundf(cornerRadius - ceilf(contentPadding / 2));
		
		shadowRadius = 8.0;
		shadowOffset = CGSizeMake(0.0, 3.0);
		shadowInsets = NSEdgeInsetsMake(shadowRadius - shadowOffset.height, shadowRadius - shadowOffset.width, shadowRadius + shadowOffset.height, shadowRadius + shadowOffset.width);
		contentInsets = NSEdgeInsetsMake(arrowSize.height + contentPadding + shadowInsets.top, contentPadding + shadowInsets.left, contentPadding + shadowInsets.bottom, contentPadding + shadowInsets.right);
	}
	
	return self;
}


- (BOOL)isFlipped
{
	return TRUE;
}


- (CGRect)arrowRect
{
	CGRect arrowRect = CGRectZero;
	arrowRect.origin.x = (self.bounds.size.width - arrowSize.width) / 2.0;
	arrowRect.origin.y = shadowInsets.top;
	arrowRect.size = arrowSize;
	return arrowRect;
}


- (void)drawRect:(NSRect)dirtyRect
{

	// Gather variables so as to be nicely copy and pastable into a custom view
	CGRect bounds = self.bounds;
	CGRect arrowRect = [self arrowRect];
	
	NSEdgeInsets arrowInsets = NSEdgeInsetsMake(arrowSize.height, 0.0, 0.0, 0.0);
	CGRect outlineRect = StashNSEdgeInsetsInsetRect(StashNSEdgeInsetsInsetRect(bounds, arrowInsets), shadowInsets);
	
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	
	CGContextSaveGState(context);
	CGSize flippedShadowOffset = shadowOffset;
	flippedShadowOffset.height *= -1;
	CGContextSetShadowWithColor(context, flippedShadowOffset, shadowRadius, [[NSColor colorWithDeviceWhite:0.5 alpha:0.5] CGColor]);
	
	CGMutablePathRef outlinePath = [self newPathForPopoverOutlineInRect:outlineRect radius:cornerRadius arrowRect:arrowRect];
	CGContextAddPath(context, outlinePath);
	CGContextSetFillColorWithColor(context, [[NSColor blackColor] CGColor]);
	CGContextSetStrokeColorWithColor(context, [[NSColor whiteColor] CGColor]);
//	CGContextSetLineWidth(context, 1.0);
//	CGContextDrawPath(context, kCGPathEOFill);
	CGContextFillPath(context);
	CGPathRelease(outlinePath);
	
	CGContextRestoreGState(context);
	
	
	// Adjust the arrow frame to the inset
	arrowRect.origin.y += contentPadding * 1.5;
	arrowRect.origin.x += contentPadding * 0.5;
	arrowRect.size.width -= contentPadding;
	arrowRect.size.height -= contentPadding * 0.5;	
	
	CGRect innerRect = StashNSEdgeInsetsInsetRect(bounds, contentInsets);
	CGMutablePathRef innerPath = [self newPathForPopoverOutlineInRect:innerRect radius:innerCornerRadius arrowRect:arrowRect];
	CGContextAddPath(context, innerPath);
	CGContextSetFillColorWithColor(context, [[NSColor whiteColor] CGColor]);
	CGContextFillPath(context);
	CGPathRelease(innerPath);
	
//	[[NSColor blueColor] setFill];
//	NSFrameRect(arrowRect);
//	NSFrameRect(bounds);
}


- (CGMutablePathRef)newPathForPopoverOutlineInRect:(CGRect)contentRect radius:(CGFloat)radius arrowRect:(CGRect)arrowRect
{
	contentRect = CGRectIntegral(contentRect);
	CGRect innerRect = CGRectInset(contentRect, radius, radius);
	
	CGMutablePathRef roundedPath = CGPathCreateMutable();
	CGPathMoveToPoint(roundedPath, NULL, CGRectGetMinX(innerRect), CGRectGetMinY(contentRect));
	
	// Draw the arrow
	CGPathAddLineToPoint(roundedPath, NULL, CGRectGetMinX(arrowRect), CGRectGetMinY(contentRect));
	CGPathAddLineToPoint(roundedPath, NULL, CGRectGetMidX(arrowRect), CGRectGetMinY(arrowRect));
	CGPathAddLineToPoint(roundedPath, NULL, CGRectGetMaxX(arrowRect), CGRectGetMinY(contentRect));
	
	// Draw the rounded rect
	CGPathAddArcToPoint(roundedPath, NULL, CGRectGetMaxX(contentRect), CGRectGetMinY(contentRect), CGRectGetMaxX(contentRect), CGRectGetMinY(innerRect), radius);
	CGPathAddArcToPoint(roundedPath, NULL,  CGRectGetMaxX(contentRect), CGRectGetMaxY(contentRect), CGRectGetMaxX(innerRect), CGRectGetMaxY(contentRect), radius);
	CGPathAddArcToPoint(roundedPath, NULL,  CGRectGetMinX(contentRect), CGRectGetMaxY(contentRect), CGRectGetMinX(contentRect), CGRectGetMaxY(innerRect), radius);
	CGPathAddArcToPoint(roundedPath, NULL,  CGRectGetMinX(contentRect), CGRectGetMinY(contentRect), CGRectGetMinX(innerRect), CGRectGetMinY(contentRect), radius);
	CGPathCloseSubpath(roundedPath);
	
	return roundedPath;
}


@end
