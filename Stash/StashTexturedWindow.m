#import "StashTexturedWindow.h"
#import "StashTexturedWindowView.h"
#import "StashViewController.h"
#import "StashDrawingFunctions.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>


NSString * const StashPreviousContentViewController = @"StashPreviousContentViewController";


@interface StashTexturedWindow ()

@property (readwrite, retain, nonatomic) StashViewController *contentViewController;
@property (strong) NSView *containerView;
@property (strong) StashTexturedWindowView *windowBackgroundView;
@end



@implementation StashTexturedWindow


- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
	
	if(self) {
		[self setMovableByWindowBackground:YES];
		[self setOpaque:FALSE];
		[self setHasShadow:FALSE];	// The background view draws the
		[self setBackgroundColor:[NSColor clearColor]];
		
		StashTexturedWindowView *windowBackgroundView = [[StashTexturedWindowView alloc] initWithFrame:[self frameRectForContentRect:contentRect]];
		[self setContentView:windowBackgroundView];
		self.windowBackgroundView = windowBackgroundView;
		
		NSView *containerView = [[NSView alloc] initWithFrame:[self contentRectForFrameRect:[windowBackgroundView bounds]]];
		containerView.wantsLayer = TRUE;
		containerView.layer.masksToBounds = TRUE;
		containerView.layer.cornerRadius = windowBackgroundView.innerCornerRadius;
		[containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		containerView.layer.backgroundColor = [[NSColor blueColor] CGColor];
		[windowBackgroundView addSubview:containerView];
		self.containerView = containerView;

	}
	
	return self;
}


- (CGRect)frameRectForContentRect:(NSRect)contentRect
{
	NSEdgeInsets contentInsets = self.windowBackgroundView.contentInsets;
	contentInsets = NSEdgeInsetsMake(-contentInsets.top, -contentInsets.left, -contentInsets.bottom, -contentInsets.right);
	
	return StashNSEdgeInsetsInsetRect(contentRect, contentInsets);
}


- (CGRect)contentRectForFrameRect:(NSRect)frameRect
{
	return StashNSEdgeInsetsInsetRect(frameRect, self.windowBackgroundView.contentInsets);
}


- (void)setContentView:(NSView *)contentView
{
	if(!self.windowBackgroundView || [contentView isEqual:self.windowBackgroundView]) {
		super.contentView = contentView;
	} else
		NSLog(@"Use StashTexturedWindow's -setContentView:animated:animationDirecton: method instead");
}


- (void)setContentViewController:(StashViewController *)destinationViewController animated:(BOOL)animated animationDirecton:(NSString *)animationDirection
{
	StashViewController *currentViewController = _contentViewController;
	
	if(currentViewController == destinationViewController)
		return;
	
	
	NSView *currentView = currentViewController.view;
	
	if(destinationViewController) {
		NSView *containerView = self.containerView;
		NSView *destinationView	= destinationViewController.view;
		destinationView.frame = self.containerView.bounds;
		destinationView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

		[destinationViewController viewWillAppear:animated];
		[currentViewController viewWillDisappear:animated];
		
		if(currentView) {

			if(animated) {
				CATransition *transition = [CATransition animation];
				transition.type = kCATransitionPush;
				transition.subtype = animationDirection ?: kCATransitionFromBottom;
				transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
				transition.duration = 1.2f;
				transition.delegate = self;
				objc_setAssociatedObject(self, (__bridge const void *)StashPreviousContentViewController, transition, OBJC_ASSOCIATION_ASSIGN);
				
				self.containerView.animations = @{ @"subviews" : transition };
				[self.containerView.animator replaceSubview:currentView with:destinationView];
			} else {
				[self.containerView replaceSubview:currentView with:destinationView];
			}
		} else {
			[containerView addSubview:destinationView];
		}
		
		if(!animated) {
			[destinationViewController viewDidAppear:animated];
			[currentViewController viewDidDisappear:animated];
		}
	} else {
		// If destinationViewController is nil then just remove the existing view. Not animated;
		[currentViewController.view removeFromSuperview];
	}
	
	self.contentViewController = destinationViewController;
}


- (void)animationDidStop:(CAAnimation *)transition finished:(BOOL)finished
{
	StashViewController *previousContentViewController = objc_getAssociatedObject(transition, (__bridge const void *)StashPreviousContentViewController);
	
	[previousContentViewController viewDidDisappear:TRUE];
	[self.contentViewController viewDidAppear:TRUE];
}


- (BOOL)canBecomeKeyWindow
{
    return YES;
}



@end