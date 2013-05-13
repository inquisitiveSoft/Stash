#import <Foundation/Foundation.h>


extern NSString * const StashRestRequestURL;
extern NSString * const StashRestRequestBody;
extern NSString * const StashRestRequestSuccessBlock;
extern NSString * const StashRestRequestFailureBlock;
extern NSString * const StashRestRequestShouldUseBasicAuthentication;

// Notifications
extern NSString * const StashDidBecomeAuthorizedNotification;
extern NSString * const StashDidResignAuthorizationNotification;

typedef void (^ AFRequestSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void (^ AFRequestFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON);
typedef void (^ AFRequestResultBlock)(BOOL success, id result);



@interface StashNetworkManager : NSObject

+ (id)sharedNetworkManager;

@property (readonly, getter = isAuthenticated) BOOL authenticated;

- (void)setUsername:(NSString *)username andPassword:(NSString *)password;
- (void)requestOAuthToken:(AFRequestResultBlock)resultBlock;

- (BOOL)setAuthorizationToken:(NSString *)token withIdentifier:(NSString *)identifier error:(NSError **)error;
- (BOOL)removeAuthentication:(NSError **)error;

- (void)performSync;
- (void)getRequest:(NSDictionary *)attributes;
- (void)postRequest:(NSDictionary *)attributes;
- (void)deleteRequest:(NSDictionary *)attributes;

@end
