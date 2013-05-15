#import "AFHTTPClient.h"
#import "AFOperationGroup.h"

typedef void (^ AFRequestSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^ AFRequestFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);


@interface StashHTTPClient : AFHTTPClient

@property (copy) NSNumber *currentTokenIdentifier;

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)pushPath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)putPath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)patchPath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
