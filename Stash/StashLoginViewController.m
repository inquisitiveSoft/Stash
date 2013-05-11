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
	self.passwordTextField.stringValue = @"JXCvWfHRsmOAH7swL6dLL";
}


- (IBAction)login:(id)sender
{
	self.userInterfaceElementsEnabled = FALSE;
	
	__weak StashLoginViewController *loginViewController = self;
	StashNetworkManager *sharedNetworkManager = [StashNetworkManager sharedNetworkManager];
	
	[sharedNetworkManager setUsername:self.usernameTextField.stringValue andPassword:self.passwordTextField.stringValue];
	[sharedNetworkManager requestOAuthTokens:^(BOOL success, id result) {
		if(success) {
			loginViewController.usernameTextField.stringValue = @"";
			loginViewController.passwordTextField.stringValue = @"";
		} else {
			loginViewController.userInterfaceElementsEnabled = TRUE;
		}
	}];
}


- (void)setUserInterfaceElementsEnabled:(BOOL)enabled
{
	self.usernameTextField.enabled = enabled;
	self.passwordTextField.enabled = enabled;
	self.loginButton.enabled = enabled;
	
	_userInterfaceElementsEnabled = enabled;
}



@end
