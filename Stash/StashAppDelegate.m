//
//  StashAppDelegate.m
//  Stash
//
//  Created by Harry Jordan on 10/05/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//

#import "StashAppDelegate.h"
#import <Security/Security.h>

#import "StashNetworkManager.h"
#import "StashIssuesManager.h"

#import "StashStatusItemController.h"
#import "StashPopoverWindowController.h"
#import "qLog.h"


@interface  StashAppDelegate ()

@property (strong) StashNetworkManager *networkManager;
@property (strong) StashIssuesManager *issueManager;

@property (strong) StashStatusItemController *statusItemController;
@property (strong) StashPopoverWindowController *issuesWindowController;

@end



@implementation StashAppDelegate


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	if([[NSUserDefaults standardUserDefaults] floatForKey:@"NSTextInsertionPointBlinkPeriod"] < 1.0)
		[[NSUserDefaults standardUserDefaults] setFloat:560.0 forKey:@"NSTextInsertionPointBlinkPeriod"];
}


- (void)awakeFromNib
{
	self.issueManager = [StashIssuesManager sharedIssuesManager];
	
	self.networkManager = [StashNetworkManager sharedNetworkManager];
	self.networkManager.issuesManager = self.issueManager;
	
	self.issuesWindowController = [[StashPopoverWindowController alloc] init];
	self.statusItemController = [[StashStatusItemController alloc] init];
	
	self.statusItemController.popoverWindowController = self.issuesWindowController;
	[self.statusItemController presentStatusBar];
}


- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	[self.statusItemController displayPopover];
}


- (void)applicationDidResignActive:(NSNotification *)notification
{
	[self.issuesWindowController.window orderOut:nil];
	[self.issueManager save];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self.issueManager save];
}

@end
