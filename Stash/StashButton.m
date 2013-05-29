#import "StashButton.h"
#import "StashNinePartImage.h"
#import "StashDrawingFunctions.h"
#import "NSObject+BlockObservation.h"


@interface StashButton () {
	StashButtonLayoutBlock _defaultLayoutBlock;
}

@property (strong) NSColor *normalTitleColor, *normalTitleShadowColor, *selectedTitleColor, *selectedTitleShadowColor;

@end


@implementation StashButton

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	
	if(self) {
		self.shadowRadius = 2.0;
		self.shadowOffset = NSMakeSize(0.0, 2.0);
		
		__weak NSButton *button = self;
		
		[self sk_observeKeyPaths:@[
			@"state", @"shadowRadius", @"shadowOffset", @"backgroundColor", @"backgroundImage", @"drawBlock"
		] change:^(id observedObject, NSString *keyPath, id oldValue, id newValue) {
			[button setNeedsDisplay];
		}];
	}
	
	return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
	StashViewDrawBlock drawBlock = self.drawBlock;
	
	if(drawBlock) {
		drawBlock(self, dirtyRect);
		return;
	}
	
	
	// Draw the buttons background
	if(self.backgroundImage) {
		NSImage *backgroundImage = self.backgroundImage;
		
		if([backgroundImage isKindOfClass:[StashNinePartImage class]]) {
			[(StashNinePartImage *)backgroundImage drawInRect:self.bounds operation:NSCompositeSourceOver fraction:1.0];
		} else {
			NSSize imageSize = [backgroundImage size];
			NSRect bounds = self.bounds;
			
			[backgroundImage drawInRect:bounds fromRect:NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height) operation:NSCompositeSourceOver fraction:1.0];
		}
	} else if(self.backgroundColor) {
		[self.backgroundColor ? : [NSColor yellowColor] setFill];
		NSRectFill(dirtyRect);
	}
	
	
	// Draw the title
	if(self.title.length || self.attributedTitle.length) {
		NSAttributedString *attributedTitle = self.attributedTitle;
		
		if(attributedTitle) {
			attributedTitle = [[NSAttributedString alloc] initWithString:self.title attributes:@{
				NSFontAttributeName : self.font,
				NSForegroundColorAttributeName : [self titleColorForState:self.state]
			}];
		}
		
		
		NSRect titleRect = NSZeroRect;
		StashButtonLayoutBlock layoutBlock = self.layoutBlock ? : [self defaultLayoutBlock];
		layoutBlock(self, &titleRect, NULL);
		
		NSColor *shadowColor = [self titleShadowColorForState:self.state];
		
		if(shadowColor) {
			CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
			CGContextSaveGState(context);
			CGContextSetShadowWithColor(context, _shadowOffset, _shadowRadius, [shadowColor CGColor]);
			
			[attributedTitle drawInRect:titleRect];
			
			CGContextRestoreGState(context);
		} else
			[attributedTitle drawInRect:titleRect];
	}
}


- (StashButtonLayoutBlock)defaultLayoutBlock
{
	if(!_defaultLayoutBlock) {
		_defaultLayoutBlock = ^(StashButton *button, NSRect *titleRect, NSRect *imageRect) {
			NSRect contentRect = StashNSEdgeInsetsInsetRect(button.bounds, button.contentInsets);
			
			if(titleRect != NULL) {
				NSRect titleFrame = NSZeroRect;
				titleFrame.size = button.attributedTitle.size;
				titleFrame.size = NSMakeSize(MIN(contentRect.size.width, titleFrame.size.width), MIN(contentRect.size.height, titleFrame.size.height));
				titleFrame.origin.x = contentRect.origin.x;
				
				// Align the title horizontally
				StashButtonTitlePosition titlePosition = button.titlePosition;
				
				if(titlePosition == StashButtonTitlePositionLeft) {
				} else if(titlePosition == StashButtonTitlePositionCenter) {
					titleFrame.origin.x += (contentRect.size.width - titleFrame.size.width) / 2.0;
				} else if(titlePosition == StashButtonTitlePositionRight) {
					titleFrame.origin.x += contentRect.size.width - titleFrame.size.width;
				}
						
				titleFrame.origin.y = floorf(contentRect.origin.y + ((contentRect.size.height - titleFrame.size.height) / 2.0));
				titleFrame = NSIntegralRect(titleFrame);
				*titleRect = titleFrame;
			}
		};
	}
	
	return _defaultLayoutBlock;
}


#pragma mark - Colors


- (void)setTitleColor:(NSColor *)color forState:(StashButtonState)state
{
	if(state == StashButtonStateSelected || state == StashButtonStateMixed)
		self.selectedTitleColor = color;
	else
		self.normalTitleColor = color;
	
	[self setNeedsDisplay];
}


- (NSColor *)titleColorForState:(StashButtonState)state
{
	NSColor *titleColor = self.normalTitleColor;
	
	if(state == StashButtonStateSelected || state == StashButtonStateMixed)
		titleColor = self.selectedTitleColor ? : titleColor;
	
	return titleColor ? : [NSColor blackColor];
}


- (void)setTitleShadowColor:(NSColor *)color forState:(StashButtonState)state
{
	if(state == StashButtonStateSelected || state == StashButtonStateMixed)
		self.selectedTitleShadowColor = color;
	else
		self.normalTitleShadowColor = color;
	
	[self setNeedsDisplay];
}


- (NSColor *)titleShadowColorForState:(StashButtonState)state
{
	NSColor *titleShadowColor = self.normalTitleShadowColor;
	
	if(state == StashButtonStateSelected || state == StashButtonStateMixed)
		titleShadowColor = self.selectedTitleShadowColor ? : titleShadowColor;
	
	return titleShadowColor;
}



- (void)dealloc
{
	[self sk_removeAllBlockObservations];
}


@end
