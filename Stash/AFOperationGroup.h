#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

//StashOperationCollectionCompletionBlock
typedef void (^ StashOperationsCompletionBlock)(NSArray *operations);


@interface AFOperationGroup : NSObject

- (id)initWithCompletionBlock:(StashOperationsCompletionBlock)completionBlock;

// Thread safe
- (void)willBeginOperation:(AFHTTPRequestOperation *)operation;
- (void)didFinishOperation:(AFHTTPRequestOperation *)operation;

@end
