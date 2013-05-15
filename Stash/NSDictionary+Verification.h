#import <Foundation/Foundation.h>


extern NSString * const StashVerificationError;


@interface NSDictionary (StashVerification)


- (BOOL)validatesAgainstExpectations:(NSDictionary *)expectedValues error:(NSError **)error;


@end
