#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@class StashIssuesManager;

extern NSString * const StashRestRequestPath;
extern NSString * const StashRestRequestBody;
extern NSString * const StashRestRequestSuccessBlock;
extern NSString * const StashRestRequestFailureBlock;
extern NSString * const StashRestRequestShouldUseBasicAuthentication;

// Notifications
extern NSString * const StashDidBecomeAuthorizedNotification;
extern NSString * const StashDidResignAuthorizationNotification;

typedef void (^ AFRequestSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^ AFRequestFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);


@interface StashNetworkManager : NSObject

+ (id)sharedNetworkManager;

@property (weak) StashIssuesManager *issuesManager;
@property (readonly, getter = isAuthenticated) BOOL authenticated;

- (void)requestOAuthTokenForUsername:(NSString *)username password:(NSString *)password success:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock;
- (BOOL)removeAuthentication:(NSError **)error;

- (void)performSync;

@end
