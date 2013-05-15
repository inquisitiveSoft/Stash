#import "AFHTTPClient.h"


@interface StashHTTPClient : AFHTTPClient

@property (copy) NSNumber *currentTokenIdentifier;

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
 attachedObject:(id)attachedObject
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
