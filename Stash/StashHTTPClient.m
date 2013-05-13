#import "StashHTTPClient.h"


@implementation StashHTTPClient

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"token %@", token]];
}

@end
