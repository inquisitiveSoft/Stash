#import "StashHTTPClient.h"
#import "AFOperationGroup.h"

#import "NSURLRequest+TokenIdentifier.h"


@implementation StashHTTPClient


- (void)setAuthorizationHeaderWithToken:(NSString *)token
{
	[self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"token %@", token]];
}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
	NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
	request.tokenIdentifier = self.currentTokenIdentifier;
	return request;
}


- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest group:(AFOperationGroup *)group success:(AFRequestSuccessBlock)success failure:(AFRequestFailureBlock)failure
{
	AFHTTPRequestOperation *operation = [super HTTPRequestOperationWithRequest:urlRequest success:success failure:failure];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if(success)
			success(operation, responseObject);
		
		[group didFinishOperation:operation];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if(failure)
			failure(operation, error);
		
		[group didFinishOperation:operation];
	}];
	
	return operation;
}





- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
	request.attachedObject = attachedObject;
	
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request group:group success:success failure:failure];
	[group willBeginOperation:operation];
	[self enqueueHTTPRequestOperation:operation];
}


- (void)pushPath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"PUSH" path:path parameters:parameters];
	request.attachedObject = attachedObject;
	
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request group:group success:success failure:failure];
	[group willBeginOperation:operation];
	[self enqueueHTTPRequestOperation:operation];
}


- (void)putPath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
	request.attachedObject = attachedObject;
	
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request group:group success:success failure:failure];
	[group willBeginOperation:operation];
	[self enqueueHTTPRequestOperation:operation];
}


- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
	request.attachedObject = attachedObject;
	
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request group:group success:success failure:failure];
	[group willBeginOperation:operation];
	[self enqueueHTTPRequestOperation:operation];
}


- (void)patchPath:(NSString *)path parameters:(NSDictionary *)parameters attachedObject:(id)attachedObject group:(AFOperationGroup *)group success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"PATCH" path:path parameters:parameters];
	request.attachedObject = attachedObject;
	
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request group:group success:success failure:failure];
	[group willBeginOperation:operation];
	[self enqueueHTTPRequestOperation:operation];
}




@end
