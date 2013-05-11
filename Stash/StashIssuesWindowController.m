#import "StashIssuesWindowController.h"

#import "StashLoginViewController.h"
#import "StashTexturedWindow.h"


@interface StashIssuesWindowController ()

@property (strong) StashLoginViewController *loginViewController;

@end



@implementation StashIssuesWindowController


- (id)init
{
	self = [super init];
	
	if(self) {
		StashTexturedWindow *window = [[StashTexturedWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 372.0, 184.0) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:TRUE];
		[window setHasShadow:TRUE];
		[window center];
		self.window = window;
		
		[self windowDidLoad];
	}
	
	return self;
}



- (void)windowDidLoad
{
	[self.window center];
	
	StashLoginViewController *loginViewController = [[StashLoginViewController alloc] initWithNibName:@"Login View" bundle:nil windowController:self];
	self.window.contentView = loginViewController.view;
	self.loginViewController = loginViewController;	
}



- (void)setStashRootMode:(StashRootMode)rootMode animated:(BOOL)animated
{

}


@end
