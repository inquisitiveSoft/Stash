#import "StashTextField.h"


@implementation StashTextField


- (NSView *)hitTest:(NSPoint)aPoint
{
	for(NSView *subview in [self subviews]) {
		if(![subview isHidden] && [subview hitTest:aPoint])
			return subview;
	}
	
	return nil;
}


@end
