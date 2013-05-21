#import "StashIssueCollectionViewItem.h"

#import "StashIssue.h"
#import "StashView.h"



@interface StashIssueCollectionViewItem ()


@end



@implementation StashIssueCollectionViewItem


- (void)awakeFromNib
{
	self.textField.font = [NSFont fontWithName:@"Lucida Grande" size:12.0];
	
	self.numberField.font = [NSFont fontWithName:@"Lucida Grande" size:11.0];
	self.numberField.textColor = [NSColor colorWithDeviceHue:0.000 saturation:0.000 brightness:0.691 alpha:1.000];
	
	[self updateFields];
}


- (void)setRepresentedObject:(id)representedObject;
{
	super.representedObject = representedObject;
	[self updateFields];
}


- (void)updateFields
{
	StashIssue *issue = self.representedObject;
	
	self.textField.stringValue = issue.title ? : @"< Title >";

	NSNumber *issueNumber = issue.number;
	self.numberField.stringValue = [issueNumber integerValue] > 0 ? [issueNumber stringValue] : @"";
}


@end
