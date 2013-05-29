#import "StashNinePartImage.h"


NSString * const StashNinePartImageCapInsetsKey = @"StashNinePartImageCapInsetsKey";


@interface StashNinePartImage ()

@property (readwrite, nonatomic) NSEdgeInsets capInsets;

@end


@implementation StashNinePartImage


- (id)copyWithZone:(NSZone *)zone
{
	StashNinePartImage *newImage = [super copyWithZone:zone];
	newImage.capInsets = self.capInsets;
	return newImage;
}


#pragma mark - Creating a resizable image

- (NSImage *)resizableImageWithCapInsets:(NSEdgeInsets)capInsets
{
	// Make sure the cap insets fit within the image size
	NSSize imageSize = self.size;
	NSAssert(capInsets.top + capInsets.bottom < imageSize.height, @"-resizableImageWithCapInsets: Vertical insets exceed the height of the image");
	NSAssert(capInsets.left + capInsets.right < imageSize.width, @"-resizableImageWithCapInsets: Horizontal insets exceed the width of the image");
	
	StashNinePartImage *newImage = [self copy];
	newImage.capInsets = capInsets;
	[newImage setFlipped:TRUE];
	return newImage;
}



#pragma mark - Drawing a resizable image


- (void)drawInRect:(NSRect)rect operation:(NSCompositingOperation)compositing fraction:(CGFloat)fraction
{
	NSEdgeInsets insets = self.capInsets;
	NSSize imageSize = self.size;
	
	if(insets.top > 0.0 || insets.left > 0.0 || insets.bottom > 0.0 || insets.right > 0.0) {
		rect = NSIntegralRect(rect);
		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextSaveGState(context);
		
		if([[NSGraphicsContext currentContext] isFlipped] != self.isFlipped) {
			rect.origin.y = - rect.origin.y;
			
			CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, imageSize.height);
			CGContextConcatCTM(context, flipVertical);
		}
		
		// Draw the top left corner
		NSRect sourceRect = NSMakeRect(0.0, 0.0, insets.left, insets.top);
		NSRect destinationRect = NSMakeRect(rect.origin.x, rect.origin.y, insets.left, insets.top);
		[self drawInRect:destinationRect fromRect:sourceRect operation:compositing fraction:fraction respectFlipped:FALSE hints:nil];
		
		// Draw the top stripe
		sourceRect = NSMakeRect(insets.left, 0.0, imageSize.width - insets.left - insets.right, insets.top);
		destinationRect = NSMakeRect(rect.origin.x + insets.left, rect.origin.y, rect.size.width - insets.left - insets.right, insets.top);
		[self drawInRect:destinationRect fromRect:sourceRect operation:compositing fraction:fraction respectFlipped:FALSE hints:nil];
		
		// Draw the top right corner
		sourceRect = NSMakeRect(imageSize.width - insets.right, 0.0, insets.right, insets.top);
		destinationRect = NSMakeRect(rect.origin.x + rect.size.width - insets.right, rect.origin.y, insets.right, insets.top);
		[self drawInRect:destinationRect fromRect:sourceRect operation:compositing fraction:fraction respectFlipped:FALSE hints:nil];
		
		// Draw the left side
		sourceRect = NSMakeRect(0.0, insets.top, insets.left, imageSize.height - insets.top - insets.bottom);
		destinationRect = NSMakeRect(rect.origin.x, rect.origin.y + insets.top, insets.left, rect.size.height - insets.top - insets.bottom);
		[self drawInRect:destinationRect fromRect:sourceRect operation:compositing fraction:fraction respectFlipped:FALSE hints:nil];
		
		// Draw the center section
		sourceRect = NSMakeRect(insets.left, insets.top, imageSize.width - insets.left - insets.right, imageSize.height - insets.top - insets.bottom);
		destinationRect = NSMakeRect(rect.origin.x + insets.left, rect.origin.y + insets.top, rect.size.width - insets.left - insets.right, rect.size.height - insets.top - insets.bottom);
		[self drawInRect:destinationRect fromRect:sourceRect operation:compositing fraction:fraction respectFlipped:FALSE hints:nil];
		
		// Draw the right side
		sourceRect = NSMakeRect(imageSize.width - insets.right, insets.top, insets.right, imageSize.height - insets.top - insets.bottom);
		destinationRect = NSMakeRect(rect.origin.x + rect.size.width - insets.right, rect.origin.y + insets.top, insets.right, rect.size.height - insets.top - insets.bottom);
		[self drawInRect:destinationRect fromRect:sourceRect operation:compositing fraction:fraction respectFlipped:FALSE hints:nil];
		
		// Draw the bottom left corner
		sourceRect = NSMakeRect(0.0, imageSize.height - insets.bottom, insets.left, insets.bottom);
		destinationRect = NSMakeRect(rect.origin.x, rect.origin.y + rect.size.height - insets.bottom, insets.left, insets.bottom);
		[self drawInRect:destinationRect fromRect:sourceRect operation:compositing fraction:fraction respectFlipped:FALSE hints:nil];

		// Draw the bottom section
		sourceRect = NSMakeRect(insets.left, imageSize.height - insets.bottom, imageSize.width - insets.left - insets.right, insets.bottom);
		destinationRect = NSMakeRect(rect.origin.x + insets.left, rect.origin.y + rect.size.height - insets.bottom, rect.size.width - insets.left - insets.right, insets.bottom);
		[self drawInRect:destinationRect fromRect:sourceRect operation:compositing fraction:fraction respectFlipped:FALSE hints:nil];

		// Draw the bottom right corner
		sourceRect = NSMakeRect(imageSize.width - insets.right, imageSize.height - insets.bottom, insets.right, insets.bottom);
		destinationRect = NSMakeRect(rect.origin.x + rect.size.width - insets.right, rect.origin.y + rect.size.height - insets.bottom, insets.left, insets.bottom);
		[self drawInRect:destinationRect fromRect:sourceRect operation:compositing fraction:fraction respectFlipped:FALSE hints:nil];
		
		CGContextRestoreGState(context);
	} else {
		[self drawInRect:rect fromRect:NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height) operation:compositing fraction:fraction respectFlipped:TRUE hints:nil];
	}
}



@end
