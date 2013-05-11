#import "StashTexturedWindowView.h"


@implementation StashTexturedWindowView


//- (id)initWithFrame:(NSRect)frame
//{
//	self = [super initWithFrame:frame];
//	
//	if(self) {
//	}
//	
//	return self;
//}


- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor whiteColor] setFill];
	NSRectFill(dirtyRect);
}


@end
