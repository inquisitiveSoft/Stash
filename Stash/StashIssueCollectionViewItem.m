#import "StashIssueCollectionViewItem.h"

#import "StashIssue.h"
#import "StashView.h"



@interface StashIssueCollectionViewItem ()


@end



@implementation StashIssueCollectionViewItem


- (void)awakeFromNib
{
	self.textField.font = [NSFont fontWithName:@"Menlo" size:13.0];
	
	self.numberField.font = [NSFont fontWithName:@"Menlo" size:11.0];
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
	self.numberField.stringValue = [NSString stringWithFormat:@"%d", 123 /*issue.numberValue*/ ] ? : @"213";
}


@end
