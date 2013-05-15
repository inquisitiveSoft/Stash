#import "StashHTTPClient.h"
#import "NSURLRequest+TokenIdentifier.h"


@implementation StashHTTPClient

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
	[self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"token %@", token]];
}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
	NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
	request.tokenIdentifier = self.currentTokenIdentifier;
	return request;
}


- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
 attachedObject:(id)attachedObject
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
	request.attachedObject = attachedObject;
	
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
	[self enqueueHTTPRequestOperation:operation];
}


@end
