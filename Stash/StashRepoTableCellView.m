#import "StashRepoTableCellView.h"

#import "StashRepo.h"
#import "StashView.h"


@interface StashRepoTableCellView ()

@property (readwrite, nonatomic) NSTextField *label;

@end



@implementation StashRepoTableCellView


- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	
	if(self) {
		CGFloat horizontalPadding = 26.0;
		frameRect.size.height -= 6.0;
		frameRect.size.width -= horizontalPadding;
		frameRect.origin.x += horizontalPadding;
		
		NSTextField *label = [[NSTextField alloc] initWithFrame:frameRect];
		label.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		label.font = [NSFont fontWithName:@"Lucida Grande" size:14.0];
		label.editable = FALSE;
		label.selectable = FALSE;
		label.bordered = FALSE;
		label.backgroundColor = [NSColor clearColor];
		[[label cell] setLineBreakMode:NSLineBreakByTruncatingTail];
		[self addSubview:label];
		
		self.label = label;
	}
	
	return self;
}


- (void)updateFields
{
//	StashRepo *repo = self.representedObject;
//	
//	if([repo isKindOfClass:[StashRepo class]])
//		self.label.stringValue = repo.name ? : @"< Repo Name >";
}


@end
