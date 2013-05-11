#import <Foundation/Foundation.h>


extern NSString * const StashRestRequestURL;
extern NSString * const StashRestRequestBody;
extern NSString * const StashRestRequestSuccessBlock;
extern NSString * const StashRestRequestFailureBlock;
extern NSString * const StashRestRequestShouldUseBasicAuthentication;


typedef void (^ AFRequestSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void (^ AFRequestFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON);
typedef void (^ AFRequestResultBlock)(BOOL success, id result);



@interface StashNetworkManager : NSObject

+ (id)sharedNetworkManager;

@property (readonly, getter = isLinked) BOOL linked;

- (void)setUsername:(NSString *)username andPassword:(NSString *)password;
- (void)requestOAuthTokens:(AFRequestResultBlock)resultBlock;

- (BOOL)setAuthorizationToken:(NSString *)token withIdentifier:(NSString *)identifier error:(NSError **)error;
- (void)removeAuthentication:(AFRequestResultBlock)resultBlock;

- (void)performSync;
- (void)getRequest:(NSDictionary *)attributes;
- (void)postRequest:(NSDictionary *)attributes;
- (void)deleteRequest:(NSDictionary *)attributes;

@end
