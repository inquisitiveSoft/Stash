#import "StashTopButton.h"


@implementation StashTopButton


- (void)setAccountName:(NSString *)accountName
{
	_accountName = accountName;
	[self setNeedsDisplay];
}


- (void)setRepoName:(NSString *)repoName
{
	_repoName = repoName;
	[self setNeedsDisplay];
}


//- (void)drawRect:(NSRect)dirtyRect
//{
//	CGRect bounds = self.bounds;
//	
//	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
//	
//	CGContextSetFillColorWithColor(context, [[NSColor colorWithDeviceHue:0.574 saturation:0.060 brightness:0.951 alpha:1.000] CGColor]);
//	CGContextFillRect(context, bounds);
//	
//	CGContextSaveGState(context);
//	
//	CGPathRef roundedRectPath = [self newPathForRoundedRect:NSInsetRect(bounds, 3.0, 3.0) radius:3.0];
//	CGContextAddPath(context, roundedRectPath);
//	CGContextClip(context);
//	CGPathRelease(roundedRectPath);
//	
//	CGContextSetFillColorWithColor(context, [[NSColor colorWithDeviceHue:0.574 saturation:0.0 brightness:0.654 alpha:1.000] CGColor]);
//	CGContextFillRect(context, bounds);
//	
//	NSRect iconRect = NSMakeRect(0.0, 0.0, 30.0, bounds.size.height);
//	iconRect = NSInsetRect(iconRect, 4.0, 4.0);
//	
//	CGContextSetFillColorWithColor(context, [[NSColor whiteColor] CGColor]);
//	CGContextFillRect(context, iconRect);
//}



- (CGMutablePathRef)newPathForRoundedRect:(CGRect)contentRect radius:(CGFloat)radius
{
	CGRect innerRect = CGRectIntegral(CGRectInset(contentRect, radius, radius));
	
	CGMutablePathRef roundedPath = CGPathCreateMutable();
	CGPathMoveToPoint(roundedPath, NULL, CGRectGetMinX(innerRect), CGRectGetMinY(contentRect));
	CGPathAddArcToPoint(roundedPath, NULL, CGRectGetMaxX(contentRect), CGRectGetMinY(contentRect), CGRectGetMaxX(contentRect), CGRectGetMinY(innerRect), radius);
	CGPathAddArcToPoint(roundedPath, NULL,  CGRectGetMaxX(contentRect), CGRectGetMaxY(contentRect), CGRectGetMaxX(innerRect), CGRectGetMaxY(contentRect), radius);
	CGPathAddArcToPoint(roundedPath, NULL,  CGRectGetMinX(contentRect), CGRectGetMaxY(contentRect), CGRectGetMinX(contentRect), CGRectGetMaxY(innerRect), radius);
	CGPathAddArcToPoint(roundedPath, NULL,  CGRectGetMinX(contentRect), CGRectGetMinY(contentRect), CGRectGetMinX(innerRect), CGRectGetMinY(contentRect), radius);
	CGPathCloseSubpath(roundedPath);
	
	return roundedPath;
}



@end
