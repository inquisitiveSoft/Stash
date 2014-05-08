#import "StashLoginViewController.h"
#import "StashNetworkManager.h"
#import "qLog.h"


@interface StashLoginViewController ()

@property (strong, nonatomic) IBOutlet NSTextField *usernameTextField;
@property (strong, nonatomic) IBOutlet NSSecureTextField *passwordTextField;
@property (strong, nonatomic) IBOutlet NSButton *loginButton;

@property (assign, nonatomic) BOOL userInterfaceElementsEnabled;

@end


@implementation StashLoginViewController


- (void)awakeFromNib
{
	self.usernameTextField.stringValue = @"inquisitiveSoft";
	self.passwordTextField.stringValue = @"nnt[du3ovDQ+T^wt,fDkvU.8RHAj";
}


- (void)viewWillAppear:(BOOL)animated
{
	self.userInterfaceElementsEnabled = TRUE;
}


- (IBAction)login:(id)sender
{
	NSString *username = self.usernameTextField.stringValue;
	NSString *password = self.passwordTextField.stringValue;
	
	if([username length] == 0) {
		// Present an error
	} else if ([password length] == 0) {
		// Present an error, highlight the password field
	} else {
		self.userInterfaceElementsEnabled = FALSE;
		
		__weak StashLoginViewController *loginViewController = self;
		[[StashNetworkManager sharedNetworkManager] requestOAuthTokenForUsername:username password:password success:NULL failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			loginViewController.userInterfaceElementsEnabled = TRUE;
		}];
	}
}


- (void)setUserInterfaceElementsEnabled:(BOOL)enabled
{
	self.usernameTextField.enabled = enabled;
	self.passwordTextField.enabled = enabled;
	self.loginButton.enabled = enabled;
	
	_userInterfaceElementsEnabled = enabled;
}



@end
