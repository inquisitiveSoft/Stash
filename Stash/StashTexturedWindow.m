#import "StashTexturedWindow.h"
#import "StashTexturedWindowView.h"


CGFloat StashTexturedWindowFramePadding = 16.0;


@interface StashTexturedWindow ()

@property (assign) NSView *childContentView;
@property (assign) NSButton *closeButton;

@end



@implementation StashTexturedWindow


- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
	
	if(self) {
		[self setMovableByWindowBackground:YES];
		[self setHasShadow:YES];
		[self setOpaque:FALSE];
		[self setBackgroundColor:[NSColor clearColor]];
		
		self.contentView = [[StashTexturedWindowView alloc] initWithFrame:NSZeroRect];
	}
	
	return self;
}


//- (NSRect)contentRectForFrameRect:(NSRect)windowFrame
//{
//	windowFrame.origin = NSZeroPoint;
//	return NSInsetRect(windowFrame, StashTexturedWindowFramePadding, StashTexturedWindowFramePadding);
//}
//
//+ (NSRect)frameRectForContentRect:(NSRect)windowContentRect styleMask:(NSUInteger)windowStyle
//{
//	return NSInsetRect(windowContentRect, -StashTexturedWindowFramePadding, -StashTexturedWindowFramePadding);
//}


- (void)setContentView:(NSView *)contentView
{
	// With thanks to http://www.cocoawithlove.com/2008/12/drawing-custom-window-on-mac-os-x.html
	NSView *childContentView = self.childContentView;
	if([childContentView isEqualTo:contentView])
		return;
	
	NSRect bounds = [self frame];
	bounds.origin = NSZeroPoint;
	
	StashTexturedWindowView *windowBackgroundView = [super contentView];
	
	if(!windowBackgroundView) {
		windowBackgroundView = [[StashTexturedWindowView alloc] initWithFrame:bounds];
		[super setContentView:windowBackgroundView];
	}
	
	if(childContentView)
		[childContentView removeFromSuperview];
	
	childContentView = contentView;
	[childContentView setFrame:[self contentRectForFrameRect:bounds]];
	[childContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[windowBackgroundView addSubview:childContentView];
	self.childContentView = childContentView;
}


- (BOOL)canBecomeKeyWindow
{
    return YES;
}



@end
