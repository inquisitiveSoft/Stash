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
	arrowRect.origin.x = floorf((self.bounds.size.width - arrowSize.width) / 2.0) - 0.5;
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
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	

	CGContextSaveGState(context);
	CGSize flippedShadowOffset = shadowOffset;
	flippedShadowOffset.height *= -1;
	CGContextSetShadowWithColor(context, flippedShadowOffset, shadowRadius, [[NSColor colorWithDeviceWhite:0.5 alpha:0.5] CGColor]);
	
	CGMutablePathRef outlinePath = [self newPathForPopoverOutlineInRect:outlineRect radius:cornerRadius arrowRect:arrowRect];
	CGContextAddPath(context, outlinePath);
	CGContextClip(context);
	CGPathRelease(outlinePath);
	
	// Draw the popover triangle
	NSColor *firstColor = [NSColor colorWithDeviceHue:0.000 saturation:0.000 brightness:0.65 alpha:1.000];
	NSColor *secondColor = [NSColor colorWithDeviceHue:0.000 saturation:0.000 brightness:0.8 alpha:1.000];
	NSColor *thirdColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.76 alpha:1.000];
	NSColor *fourthColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.72 alpha:1.000];
	NSColor *fifthColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.75 alpha:1.000];
	NSColor *sixthColor = [NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.76 alpha:1.000];
	
	NSArray *colors = @[
		(__bridge_transfer id)[firstColor CGColor],
		(__bridge_transfer id)[secondColor CGColor],
		(__bridge_transfer id)[thirdColor CGColor],
		(__bridge_transfer id)[fourthColor CGColor],
		(__bridge_transfer id)[fifthColor CGColor],
		(__bridge_transfer id)[sixthColor CGColor],
	];
	
	CGFloat locations[6];
	locations[0] = 0.0;
	locations[1] = 0.05;
	locations[2] = 0.2;
	locations[3] = 0.7;
	locations[4] = 0.93;
	locations[5] = 1.0;
	
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge_retained CFArrayRef)colors, locations);
	CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, arrowRect.origin.y), CGPointMake(0.0, outlineRect.origin.y + outlineRect.size.height), 0);
	CGGradientRelease(gradient);
	CGContextRestoreGState(context);
	
	
	// Adjust the arrow frame to the inset
	arrowRect.origin.y += 1.5;
	
	CGMutablePathRef innerArrowPath = CGPathCreateMutable();
	CGPathMoveToPoint(innerArrowPath, NULL, CGRectGetMinX(arrowRect), CGRectGetMaxY(arrowRect));	
	CGPathAddLineToPoint(innerArrowPath, NULL, CGRectGetMidX(arrowRect), CGRectGetMinY(arrowRect));
	CGPathAddLineToPoint(innerArrowPath, NULL, CGRectGetMaxX(arrowRect), CGRectGetMaxY(arrowRect));
	CGPathCloseSubpath(innerArrowPath);
	
	CGContextAddPath(context, innerArrowPath);
	CGContextSetFillColorWithColor(context, [[NSColor colorWithDeviceHue:0.667 saturation:0.004 brightness:0.921 alpha:1.000] CGColor]);
	CGContextFillPath(context);
		
	CGColorSpaceRelease(colorSpace);
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
