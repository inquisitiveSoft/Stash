#import "AFOperationGroup.h"


@interface AFOperationGroup () {
	dispatch_queue_t _internalQueue;
	__strong StashOperationsCompletionBlock _completionBlock;

	__block NSInteger _numberOfActiveOperations;
	__block NSMutableArray *_operations;
}


@end


@implementation AFOperationGroup


- (id)initWithCompletionBlock:(StashOperationsCompletionBlock)completionBlock;
{
	self = [super init];
	
	if(self) {
		_internalQueue = dispatch_queue_create("StashOperationCollection internal queue", DISPATCH_QUEUE_SERIAL);
		_completionBlock = completionBlock;
		
		// The following variables should only be modified from a block running on the _internalQueue
		_numberOfActiveOperations = 0;
		_operations = [[NSMutableArray alloc] init];
	}
	
	return self;
}


- (void)willBeginOperation:(AFHTTPRequestOperation *)operation
{
	if(operation) {
		dispatch_sync(_internalQueue, ^{
			_numberOfActiveOperations++;
			[_operations addObject:operation];
		});
	}
}


- (void)didFinishOperation:(AFHTTPRequestOperation *)operation
{
	dispatch_sync(_internalQueue, ^{
		_numberOfActiveOperations--;
		
		if(_numberOfActiveOperations == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if(_completionBlock)
					_completionBlock(_operations);
			});
		}
	});
}


@end
