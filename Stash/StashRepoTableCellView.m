#import "StashRepoTableCellView.h"

#import "StashRepo.h"
#import "StashView.h"


@interface StashRepoTableCellView ()

@property (readwrite, nonatomic) NSTextField *numberLabel;

@end



@implementation StashRepoTableCellView


- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self) {
		CGFloat horizontalPadding = 42.0;
		
		CGRect imageRect = frame;
		imageRect.origin.x += 6.0;
		imageRect.size.width = imageRect.size.height;
		imageRect = NSInsetRect(imageRect, 0.0, 0.0);
		
		NSImageView *imageView = [[NSImageView alloc] initWithFrame:imageRect];
		[self addSubview:imageView];
		self.imageView = imageView;
		
		CGRect labelRect = frame;
		labelRect.size.height -= 7.0;
		labelRect.size.width -= horizontalPadding + 22.0;
		labelRect.origin.x += horizontalPadding;
		
		NSTextField *label = [[NSTextField alloc] initWithFrame:labelRect];
		label.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		label.font = [NSFont fontWithName:@"Lucida Grande" size:13.0];
		label.editable = FALSE;
		label.selectable = FALSE;
		label.bordered = FALSE;
		label.backgroundColor = [NSColor clearColor];
		[[label cell] setLineBreakMode:NSLineBreakByTruncatingTail];
		[self addSubview:label];
		self.textField = label;
		
		CGRect numberRect = frame;
		numberRect.size.height -= 6.0;
		numberRect.size.width = 30.0;
		numberRect.origin.x = frame.size.width - 40.0;
		numberRect.origin.y = 0.0;
		
		NSTextField *numberLabel = [[NSTextField alloc] initWithFrame:numberRect];
		numberLabel.alignment = NSRightTextAlignment;
		numberLabel.autoresizingMask = NSViewMinXMargin | NSViewHeightSizable;
		numberLabel.font = [NSFont fontWithName:@"Menlo Bold" size:11.0];
		numberLabel.textColor = [NSColor grayColor];
		numberLabel.editable = FALSE;
		numberLabel.selectable = FALSE;
		numberLabel.bordered = FALSE;
		numberLabel.backgroundColor = [NSColor clearColor];
		[self addSubview:numberLabel];
		self.numberLabel = numberLabel;
	}
	
	return self;
}


@end
