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
#import "StashIssuesWindowController.h"
#import "qLog.h"


@interface  StashAppDelegate ()

@property (strong) StashNetworkManager *networkManager;

@property (strong) StashIssuesWindowController *issuesWindowController;

@end



@implementation StashAppDelegate


- (void)awakeFromNib
{
	self.issuesWindowController = [[StashIssuesWindowController alloc] init];
}


- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	[self.issuesWindowController.window makeKeyAndOrderFront:nil];
}


@end
