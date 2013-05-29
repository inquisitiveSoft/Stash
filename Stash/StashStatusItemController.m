#import "StashStatusItemController.h"

#import "StashPopoverWindowController.h"
#import "StashTexturedWindow.h"
#import "qLog.h"


@interface StashStatusItemController ()

@property (readwrite, retain, nonatomic) NSStatusItem *statusItem;
@property (readwrite, retain, nonatomic) NSButton *statusItemButton;

@end


@implementation StashStatusItemController


- (void)presentStatusBar
{
	if(self.statusItem)
		return;
	
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
	
	NSButton *statusItemButton = [[NSButton alloc] initWithFrame:NSZeroRect];
	statusItemButton.target = self;
	statusItemButton.action = @selector(handleSingleClick:);
	
	// Style the button
	statusItemButton.bordered = FALSE;
	statusItemButton.buttonType = NSToggleButton;
	statusItemButton.title = @"";
	statusItemButton.image = [NSImage imageNamed:@"Status Item Icon"];
	statusItemButton.alternateImage = [NSImage imageNamed:@"Status Item Icon - Highlighted"];
	[statusItemButton.cell setHighlightsBy:NSContentsCellMask];
	self.statusItemButton = statusItemButton;
	
	NSStatusItem *statusItem = [statusBar statusItemWithLength:32.0];
	statusItem.toolTip = NSLocalizedString(@"Stash ideas and issues in GitHub", @"Tooltip");
	statusItem.view = statusItemButton;
	self.statusItem = statusItem;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screensDidChange:) name:NSApplicationDidChangeScreenParametersNotification object:nil];
}


- (void)screensDidChange:(NSNotification *)notification
{
	[self hidePopover];
}


- (void)updatePopoverAttachmentPosition
{
	CGRect statusItemRect = self.statusItem.view.window.frame;
	CGPoint attachmentPosition = CGPointMake(CGRectGetMidX(statusItemRect), CGRectGetMinY(statusItemRect) + 2.0);
	
	StashTexturedWindow *popoverWindow = (StashTexturedWindow *)self.popoverWindowController.window;
	popoverWindow.attachmentPosition = attachmentPosition;
}



- (BOOL)isPopoverVisible
{
	return self.popoverWindowController.window.isVisible;
}


- (void)displayPopover
{
	[self updatePopoverAttachmentPosition];
	[self.popoverWindowController displayWindow:TRUE];
}


- (void)hidePopover
{
	[self.popoverWindowController hideWindow:TRUE];
}


#pragma Event handling


- (void)handleSingleClick:(id)sender
{
	[[NSApplication sharedApplication] activateIgnoringOtherApps:TRUE];
	
	if([self isPopoverVisible])
		[self hidePopover];
	else
		[self displayPopover];
}



@end
