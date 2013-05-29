#import "StashIssuesTableCellView.h"

#import "StashIssue.h"
#import "StashView.h"
#import "StashNinePartImage.h"

@implementation StashIssuesTableCellView


- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self) {
		NSTextField *label = [[NSTextField alloc] initWithFrame:NSZeroRect];
		label.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		label.font = [self labelFont];
		label.editable = FALSE;
		label.selectable = FALSE;
		label.bordered = FALSE;
		label.backgroundColor = [NSColor clearColor];
		[[label cell] setLineBreakMode:NSLineBreakByTruncatingTail];
		[self addSubview:label];
		self.textField = label;
				
		NSTextField *numberLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
		numberLabel.autoresizingMask = NSViewMinXMargin;
		numberLabel.alignment = NSCenterTextAlignment;
		numberLabel.font = [NSFont fontWithName:@"Menlo Bold" size:10.0];
		numberLabel.textColor = [NSColor grayColor];
		numberLabel.editable = FALSE;
		numberLabel.selectable = FALSE;
		numberLabel.bordered = FALSE;
		numberLabel.backgroundColor = [NSColor clearColor];
		[self addSubview:numberLabel];
		self.numberLabel = numberLabel;
		
		NSButton *checkboxButton = [[NSButton alloc] initWithFrame:NSZeroRect];
		[checkboxButton setButtonType:NSMomentaryChangeButton];
		[checkboxButton setBordered:FALSE];
		[checkboxButton setAction:@selector(toggleCheckbox:)];
		[checkboxButton setTarget:self];
		[self addSubview:checkboxButton];
		self.checkboxButton = checkboxButton;
		
		[self layoutSubviews];
	}
	
	return self;
}


- (NSFont *)labelFont
{
	return [NSFont fontWithName:@"Avenir Next Medium" size:12.0];
}


- (void)setIssue:(StashIssue *)issue
{
	_issue = issue;
	
	self.textField.stringValue = [issue.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	self.numberLabel.stringValue = [issue.number stringValue] ? : @"";
	
	[self updateCheckboxState];
	[self layoutSubviews];
}


- (void)layoutSubviews
{
	NSRect bounds = self.bounds;
	CGFloat leftPadding = 35.0;
	CGFloat numberInset = 15.0;
	CGFloat rightPadding = 2.0;
	
	NSRect numberRect = [self.numberLabel.attributedStringValue boundingRectWithSize:NSZeroSize options:0];
	numberRect.size.width += 6.0;
	numberRect.origin.y = ((bounds.size.height - numberRect.size.height) / 2.0) - 1.0;
	numberRect.origin.x = bounds.size.width - floorf(numberRect.size.width / 2.0) - numberInset;
	
	if((numberRect.size.width / 2.0) > (numberInset - rightPadding))
		numberRect.origin.x = bounds.size.width - numberRect.size.width - rightPadding;
	
	self.numberLabel.frame = CGRectIntegral(numberRect);
	
	NSRect labelRect = bounds;
	labelRect.origin.x += leftPadding;
	labelRect.origin.x -= 2.0;
	labelRect.size.height -= 1.0;
	labelRect.size.width = numberRect.origin.x - leftPadding - 3.0;
	self.textField.frame = labelRect;
	
	NSRect checkboxFrame = bounds;
	checkboxFrame.size.width = 34.0;
	checkboxFrame.size.height -= 4.0;
	checkboxFrame.origin.y += 1.0;
	self.checkboxButton.frame = checkboxFrame;
}


- (void)toggleCheckbox:(id)sender
{
	self.issue.stateValue = !self.issue.stateValue;
	
	[self updateCheckboxState];
}


- (void)updateCheckboxState
{
	NSString *checkboxImageName = @"Issues Checkbox";
	if(self.issue.stateValue)
		checkboxImageName = @"Issues Checkbox Selected";
	
	self.checkboxButton.image = [NSImage imageNamed:checkboxImageName];
}


- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
	NSLog(@"backgroundStyle: %ld", backgroundStyle);
}


- (NSBackgroundStyle)backgroundStyle
{
	return NSBackgroundStyleLight;
}


- (void)drawRect:(NSRect)dirtyRect
{
//	NSRect selectionRect = NSInsetRect(self.bounds, 6.0, 1.0);
//	StashNinePartImage *selectionImage = (StashNinePartImage *)[[StashNinePartImage imageNamed:@"Issues Selection"] resizableImageWithCapInsets:NSEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)];
//	[selectionImage drawInRect:selectionRect operation:NSCompositeSourceOver fraction:1.0];
}



@end

