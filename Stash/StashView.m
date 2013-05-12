#import "StashView.h"


@implementation StashView


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	if(self.backgroundColor) {
		[self.backgroundColor ? : [NSColor yellowColor] setFill];
		NSRectFill(dirtyRect);
	}
}


@end
