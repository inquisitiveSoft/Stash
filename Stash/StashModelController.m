#import "StashModelController.h"


@implementation StashModelController


+ (id)sharedModelController {
	static StashModelController *__sharedModelController = nil;
	static dispatch_once_t createSharedModelController;
	dispatch_once(&createSharedModelController, ^{
		__sharedModelController = [[StashModelController alloc] init];
	});
	
	return __sharedModelController;
}


- (id)init {
	self = [super init];
	
	if(self) {
		
	}
	
	return self;
}





@end
