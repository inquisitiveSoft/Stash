#import "NSDictionary+Verification.h"


NSString * const StashVerificationError = @"StashVerificationError";


@implementation NSDictionary (StashVerification)


- (BOOL)validatesAgainstExpectations:(NSDictionary *)expectedValues error:(NSError **)error
{
	__block BOOL isValid = TRUE;
	__weak NSDictionary *contents = self;
	__block NSMutableString *errorMessage = nil;
	
	[expectedValues enumerateKeysAndObjectsUsingBlock:^(id key, Class class, BOOL *stop) {
		if([key length]) {
			id object = contents[key];
			
			if(![object isKindOfClass:class]) {
				if(!errorMessage)
					errorMessage = [[NSMutableString alloc] init];
				
				if(object) {
					[errorMessage appendFormat:@"Validation Error. Invalid object for key:'%@'. Expected type:'%@' rather than:'%@' %@\n", key, class, [object class], object];
				} else {
					[errorMessage appendFormat:@"Validation Error. Missing object for key:'%@'\n", key];				
				}
				
				isValid = FALSE;
			}
		}
	}];
	
	if([errorMessage length]) {
		if(error != NULL) {
			*error = [NSError errorWithDomain:StashVerificationError code:0 userInfo:@{
				NSLocalizedDescriptionKey : errorMessage
			}];
		} else
			NSLog(@"validatesAgainstExpectations:error: %@", errorMessage);
	}
	
	return isValid;
}


@end
