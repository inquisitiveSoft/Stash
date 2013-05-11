#import "StashStatusItemController.h"

#import "StashTexturedWindow.h"


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
	
	NSButton *statusItemButton = [[NSButton alloc] initWithFrame:CGRectZero];
	statusItemButton.target = self;
	statusItemButton.action = @selector(handleSingleClick:);
	
	// Style the button
	statusItemButton.bordered = FALSE;
	statusItemButton.buttonType = NSMomentaryLightButton;
	statusItemButton.title = @"";
	statusItemButton.image = [NSImage imageNamed:@"Icon"];
	self.statusItemButton = statusItemButton;
	
	NSStatusItem *statusItem = [statusBar statusItemWithLength:32.0];
	statusItem.toolTip = NSLocalizedString(@"Squirreling", @"Tooltip");
	statusItem.highlightMode = TRUE;
	statusItem.view = statusItemButton;
	
	self.statusItem = statusItem;
}


- (void)handleSingleClick:(id)sender
{
	
}


@end
