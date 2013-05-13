#import "StashIssuesWindowController.h"

#import "StashNetworkManager.h"

#import "StashLoginViewController.h"
#import "StashIssuesViewController.h"

#import "StashViewController.h"
#import "StashTexturedWindow.h"
#import "StashView.h"

#import <QuartzCore/QuartzCore.h>
#import "qLog.h"
#import "NSView+ConstraintAdditions.h"


@interface StashIssuesWindowController ()

@property (strong) StashLoginViewController *loginViewController;
@property (strong) StashIssuesViewController *issuesViewController;

@property (strong) NSView *containerView, *currentContentView;

@end



@implementation StashIssuesWindowController


- (id)init
{
	self = [super init];
	
	if(self) {
		[self setup];
	}
	
	return self;
}



- (void)setup
{
	CGRect windowFrame = NSMakeRect(0.0, 0.0, 300.0, 400.0);
	StashTexturedWindow *window = [[StashTexturedWindow alloc] initWithContentRect:windowFrame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:TRUE];
	window.delegate = self;
	self.window = window;
	
	self.loginViewController = [[StashLoginViewController alloc] initWithNibName:@"Login View" bundle:nil windowController:self];
	self.issuesViewController = [[StashIssuesViewController alloc] initWithNibName:@"Issues View" bundle:nil windowController:self];
	
	StashRootMode rootMode = [[StashNetworkManager sharedNetworkManager] isAuthenticated] ? StashRootModeIssues : StashRootModeLogin;
	[self setRootMode:rootMode animated:FALSE];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeAuthorized:) name:StashDidBecomeAuthorizedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResignAuthorization:) name:StashDidResignAuthorizationNotification object:nil];
}



- (void)displayWindow:(BOOL)animated
{
	[self.window makeKeyAndOrderFront:nil];
}


- (void)hideWindow:(BOOL)animated
{
	[self.window orderOut:nil];
}


- (void)setRootMode:(StashRootMode)rootMode animated:(BOOL)animated
{
	if(_rootMode == rootMode)
		return;
	
	
	NSString *animationDirectiong = rootMode > _rootMode ? kCATransitionFromRight : kCATransitionFromLeft;
	StashViewController *destinationViewController = [self viewControllerForMode:rootMode];
	
	[(StashTexturedWindow *)self.window setContentViewController:destinationViewController animated:animated animationDirecton:animationDirectiong];
	
	[self willChangeValueForKey:@"rootMode"];
	_rootMode = rootMode;
	[self didChangeValueForKey:@"rootMode"];
}


- (StashViewController *)viewControllerForMode:(StashRootMode)mode
{
	if(mode == StashRootModeLogin) {
		return self.loginViewController;
	}
	
	return self.issuesViewController;
}


#pragma mark - Update to match the current authorization state

- (void)didBecomeAuthorized:(NSNotification *)notification
{
	[self setRootMode:StashRootModeIssues animated:TRUE];
}


- (void)didResignAuthorization:(NSNotification *)notification
{
	[self setRootMode:StashRootModeLogin animated:TRUE];
}


#pragma mark - NSWindowDelegate methods

- (void)windowDidResignKey:(NSNotification *)notification
{
	[self hideWindow:TRUE];
}


@end



