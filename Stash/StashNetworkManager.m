#import "StashNetworkManager.h"

#import <Security/Security.h>
#import "RegexKitLite.h"

#import "AFNetworking.h"
#import "StashIssuesManager.h"
#import "StashHTTPClient.h"
#import "qLog.h"

#import "AFHTTPRequestOperation+StashAdditions.h"


#define GITHUB_CLIENT_ID @"6e5a15de184327604f1d"
#define GITHUB_CLIENT_SECRET @"b33b8a9e8eddc2ac92db733621d0b013e85cfde5"

NSString * const StashDefaultGitHubAPILocation = @"https://api.github.com/";
NSString * const StashGitHubPerPageParameter = @"per_page";

NSString * const StashRestRequestPath = @"StashRestRequestPath";
NSString * const StashRestRequestBody = @"StashRestRequestBody";
NSString * const StashRestRequestSuccessBlock = @"StashRestRequestSuccessBlock";
NSString * const StashRestRequestFailureBlock = @"StashRestRequestFailureBlock";
NSString * const StashRestRequestShouldUseBasicAuthentication = @"StashRestRequestShouldUseBasicAuthentication";

// Notifications
NSString * const StashDidBecomeAuthorizedNotification = @"StashDidBecomeAuthorizedNotification";
NSString * const StashDidResignAuthorizationNotification = @"StashDidResignAuthorizationNotification";

//
NSString * const StashRestRequestMethod = @"StashRestRequestMethod";
NSString * const StashRestRequestMethodGET = @"GET";
NSString * const StashRestRequestMethodPOST = @"POST";
NSString * const StashRestRequestMethodDELETE = @"DELETE";

NSString * const StashOAuthTokenKey = @"token";
NSString * const StashOAuthIdentifierKey = @"id";

NSString * const StashOAuthKeychainIdentifier = @"com.inquisitiveSoftware.Stash.OAuthToken";
NSString * const StashKeychainError = @"StashKeychainError";
NSString * const StashRequestUnxpectedFormatError = @"StashRequestUnxpectedFormatError";

static NSString *StashBase64EncodedStringFromString(NSString *string);



@interface StashNetworkManager ()

@property (strong) AFHTTPClient *httpClient;
@property (readwrite, getter = isAuthenticated) BOOL authenticated;
@property NSDictionary *api;

@end



@implementation StashNetworkManager


+ (id)sharedNetworkManager
{
	static StashNetworkManager *__sharedStashNetworkManager = nil;
	
	static dispatch_once_t createSharedStashNetworkManager;
	dispatch_once(&createSharedStashNetworkManager, ^{
		__sharedStashNetworkManager = [[StashNetworkManager alloc] initSharedNetworkManager];
	});
	
	return __sharedStashNetworkManager;
}



- (id)init
{
	NSAssert(FALSE, @"Treat the network manager as a singleton. Call +[StashNetworkManager sharedNetworkManager] instead");
	return nil;
}


- (id)initSharedNetworkManager
{
	self = [super init];
	
	if(self) {
		[self setup];
	}
	
	return self;
}


- (void)setup
{
	NSURL *baseURL = [NSURL URLWithString:StashDefaultGitHubAPILocation];
	
	StashHTTPClient *httpClient = [[StashHTTPClient alloc] initWithBaseURL:baseURL];
	self.httpClient = httpClient; 
	
	[httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[httpClient setParameterEncoding:AFJSONParameterEncoding];
	[httpClient setDefaultHeader:@"Accept" value:@"application/json"];
	
	NSString *authorizationToken = [self authorizationToken];
	if([authorizationToken length]) {
		[httpClient setAuthorizationHeaderWithToken:authorizationToken];
		self.authenticated = TRUE;
	}
	
	
	// Load the latest api endpoints
	[self.httpClient getPath:nil parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
		self.api = result;
		
		if(self.authenticated) {
			[self performSync];
		}
	} failure:NULL];
}


/*
{
    "current_user_url": "https://api.github.com/user",
    "authorizations_url": "https://api.github.com/authorizations",
    "emails_url": "https://api.github.com/user/emails",
    "emojis_url": "https://api.github.com/emojis",
    "events_url": "https://api.github.com/events",
    "following_url": "https://api.github.com/user/following{/target}",
    "gists_url": "https://api.github.com/gists{/gist_id}",
    "hub_url": "https://api.github.com/hub",
    "issue_search_url": "https://api.github.com/legacy/issues/search/{owner}/{repo}/{state}/{keyword}",
    "issues_url": "https://api.github.com/issues",
    "keys_url": "https://api.github.com/user/keys",
    "notifications_url": "https://api.github.com/notifications",
    "organization_repositories_url": "https://api.github.com/orgs/{org}/repos/{?type,page,per_page,sort}",
    "organization_url": "https://api.github.com/orgs/{org}",
    "public_gists_url": "https://api.github.com/gists/public",
    "rate_limit_url": "https://api.github.com/rate_limit",
    "repository_url": "https://api.github.com/repos/{owner}/{repo}",
    "repository_search_url": "https://api.github.com/legacy/repos/search/{keyword}{?language,start_page}",
    "current_user_repositories_url": "https://api.github.com/user/repos{?type,page,per_page,sort}",
    "starred_url": "https://api.github.com/user/starred{/owner}{/repo}",
    "starred_gists_url": "https://api.github.com/gists/starred",
    "team_url": "https://api.github.com/teams",
    "user_url": "https://api.github.com/users/{user}",
    "user_organizations_url": "https://api.github.com/user/orgs",
    "user_repositories_url": "https://api.github.com/users/{user}/repos{?type,page,per_page,sort}",
    "user_search_url": "https://api.github.com/legacy/user/search/{keyword}"
}
*/


- (NSString *)apiForKey:(NSString *)apiKey
{
	return [self apiForKey:apiKey parameters:nil];
}


- (NSString *)apiForKey:(NSString *)apiKey parameters:(NSDictionary *)parameters
{
	if(![apiKey length])
		return @"";
	
	NSString *originalPath = [self.api objectForKey:apiKey];
	
	NSString *pattern = [NSString stringWithFormat:@"^%@([A-Za-z0-9/_-]*)(\\{\\?(.*)\\})?", StashDefaultGitHubAPILocation];
	__block NSMutableString *apiPath = [[originalPath stringByMatching:pattern capture:1] mutableCopy];

	NSArray *validParameters = [[originalPath stringByMatching:pattern capture:3] componentsSeparatedByString:@","];
	
	// If the allowed parameters include the per_page then set it at 100
	if([validParameters containsObject:StashGitHubPerPageParameter] && ![parameters objectForKey:StashGitHubPerPageParameter]) {
		NSMutableDictionary *modifiedParameters = [parameters mutableCopy];
		[modifiedParameters setObject:@(100) forKey:StashGitHubPerPageParameter];
		parameters = modifiedParameters;
	}
	
	if([parameters count]) {
		__block BOOL isFirstParameter = TRUE;
		
		[parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
			if([validParameters containsObject:key]) {
				NSString *prefix = @"";
				if(isFirstParameter) {
					prefix = @"?";
				} else {
					prefix = @"&";
				}
				
				[apiPath appendFormat:@"%@%@=%@", prefix, key, value];
			}
		}];
	}
	
	return apiPath;
}


#pragma mark - Requesting and validating authorizations


- (void)requestOAuthTokenForUsername:(NSString *)username password:(NSString *)password success:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock
{
	if([self isAuthenticated]) {
		qLog(@"StashNetworkManager is already authenticated");
		return;
	}
	
	if([username length] == 0 || [password length] || 0) {
		qLog(@"Requires both a username (%@) and password (%@)", username, password);
	}
	
	[self.httpClient setAuthorizationHeaderWithUsername:username password:password];
	StashAccount *account = [self.issuesManager accountForUsername:username];
	NSNumber *existingTokenIdentifier = account.identifier;
	
	if(existingTokenIdentifier) {
		[self requestExistingOAuthTokenForIdentifier:existingTokenIdentifier success:successBlock failure:failureBlock];
	} else {
		[self requestNewOAuthToken:successBlock failure:failureBlock];
	}
}


- (void)requestExistingOAuthTokenForIdentifier:(NSNumber *)tokenIdentifier success:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock
{
	if(![tokenIdentifier isKindOfClass:[NSNumber class]]) {
		qError(@"Requires a tokenIdentifier");
		return;
	}
	
	
	NSString *requestPath = [NSString stringWithFormat:@"%@/%@", self.api[@"authorizations_url"], tokenIdentifier];
	
	[self.httpClient getPath:requestPath parameters:@{
		@"client_id" : GITHUB_CLIENT_ID,
		@"client_secret" : GITHUB_CLIENT_SECRET
	} success:^(AFHTTPRequestOperation *httpOperation, id json) {
		BOOL success = FALSE;
		
		if([json isKindOfClass:[NSDictionary class]]) {
			NSString *authorizationToken = [json objectForKey:StashOAuthTokenKey];
			NSNumber *authorizationIdentifier = [json objectForKey:StashOAuthIdentifierKey];
			
			NSError *error = nil;
			printf("Found existing token for id: %ld", [authorizationIdentifier integerValue]);
			success = [self setAuthorizationToken:authorizationToken withIdentifier:authorizationIdentifier error:&error];
			
			if(!success && error) {
				qLog(@"There was an error writing to the Keychain: %@", error);
			}
		}
		
		if(successBlock) {
			successBlock(httpOperation, json);
		}
	} failure:^(AFHTTPRequestOperation *httpOperation, NSError *error) {
		if(httpOperation.response.statusCode == 404) {
			qLog(@"Recieved 404 while looking for an existing token. It's likely the previous token was deleted from the applications list. Requesting a new token");
			[self requestNewOAuthToken:successBlock failure:failureBlock];
		} else if(failureBlock) {
			failureBlock(httpOperation, error);
		}
	}];
}


- (void)requestNewOAuthToken:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock
{
	[self.httpClient postPath:self.api[@"authorizations_url"] parameters:@{
		@"scopes" : @[@"user", @"public_repo", @"repo", @"notifications"],
		@"client_id" : GITHUB_CLIENT_ID,
		@"client_secret" : GITHUB_CLIENT_SECRET
	} success:^(AFHTTPRequestOperation *httpOperation, NSDictionary *json) {
		BOOL success = FALSE;
		
		if([json isKindOfClass:[NSDictionary class]]) {
			NSString *authorizationToken = [json objectForKey:StashOAuthTokenKey];
			NSNumber *authorizationIdentifier = [json objectForKey:StashOAuthIdentifierKey];
			
			NSError *error = nil;
			success = [self setAuthorizationToken:authorizationToken withIdentifier:authorizationIdentifier error:&error];
			
			if(success)
				[self performSync];
			else if(error)
				qLog(@"There was an error writing to the Keychain: %@", error);
		}
		
		if(successBlock) {
			successBlock(httpOperation, json);
		}
	} failure:failureBlock];
}



#pragma mark - 


- (void)performSync
{
	//		Get /user/repos
	//			for each get
	//				issues, milestones, label, users
	//            per_page=100
	
	// Fetch the user info
	StashAccount *currentAccount = self.issuesManager.currentAccount;
	
	[self.httpClient getPath:self.api[@"current_user_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
		// Test the date stamps to see if there have been changes on the server
		NSDate *dateStampOfLastSync = currentAccount.dateStampOfLastSync;
		NSDate *dateOfLastModification = [operation dateOfLastModification];
		
		BOOL hasChangesToPull = !(dateStampOfLastSync && dateOfLastModification && [dateOfLastModification timeIntervalSinceDate:dateStampOfLastSync] < 0);
		
		if(hasChangesToPull) {
			[self.issuesManager updateAccountDetailsWithJSON:response];
			
			[self pullChanges:^(AFHTTPRequestOperation *operation, id responseObject) {
				// Push changes
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				
			}];
		}
		
		currentAccount.dateStampOfLastSync = [operation dateStamp];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
	}];
}


- (void)pullChanges:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock
{
	// Request repos	
	[self.httpClient getPath:[self apiForKey:@"current_user_repositories_url"] parameters:0 success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
		NSInteger numberOfIssues = [response count];
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
//		qLog(@"count %d - '%@'", numberOfIssues, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
		
		if(successBlock) {
			successBlock(operation, response);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		qLog(@"Couldn't retrieve repos: %@", error);
		
		if(failureBlock) {
			failureBlock(operation, error);
		}
	}];
}



//- (void)requestUsersRepos:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock
//{
//	[self.httpClient getPath:self.api[@"current_user_repositories_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
//		NSInteger numberOfIssues = [response count];
//		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
//		qLog(@"count %d - '%@'", numberOfIssues, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
//		
//		if(successBlock) {
//			successBlock(operation, response);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		qLog(@"Couldn't retrieve repos: %@", error);
//		
//		if(failureBlock) {
//			failureBlock(operation, error);
//		}
//	}];
//}




#pragma mark - Storing authorization tokens in the keychain


- (NSString *)authorizationToken
{
	NSError *error = nil;
	NSString *authorizationToken = [self authorizationObjectForKey:StashOAuthTokenKey error:&error];
	
	if(authorizationToken) {
		[self.httpClient setAuthorizationHeaderWithToken:authorizationToken];
	} else if(error) {
		qLog(@"There was an error loading the authorizationToken: '%@'", error);
	}
	
	return authorizationToken;
}


- (NSNumber *)authorizationIdentifier
{
	NSError *error = nil;
	NSNumber *authorizationIdentifier = [self authorizationObjectForKey:StashOAuthIdentifierKey error:&error];
	
	if(authorizationIdentifier) {
		if(![authorizationIdentifier isKindOfClass:[NSNumber class]]) {
			qLog(@"authorizationIdentifier is expected to be an NSNumber, rather than an: %@ of %@ class", authorizationIdentifier, [authorizationIdentifier class]);
		}
	} else if(error) {
		qLog(@"There was an error reading the authorizationIdentifier: %@", error);
	}
	
	return authorizationIdentifier;
}


- (id)authorizationObjectForKey:(NSString *)tokenKey error:(NSError **)error
{
	if([tokenKey length] == 0) {
		return nil;
	}

	NSDictionary *matchingAttributes = @{
		(id)kSecClass : (id)kSecClassGenericPassword,
		(id)kSecAttrService : StashOAuthKeychainIdentifier,
	};
	
	SecKeychainItemRef storedItem = NULL;
	OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)matchingAttributes, (CFTypeRef *)&storedItem);
	NSString *authorizationObject = nil;
	
	if(result == errSecSuccess) {
		UInt32 length = 0;
		void *bytes = NULL;
		result = SecKeychainItemCopyAttributesAndData(storedItem, NULL, NULL, NULL, &length, &bytes);
		
		if(result == errSecSuccess && bytes) {
			NSData *storedData = [NSData dataWithBytes:bytes length:length];
			
			if(storedData) {
				id tokenDictionary = [NSJSONSerialization JSONObjectWithData:storedData options:0 error:error];
				authorizationObject = [tokenDictionary objectForKey:tokenKey];
			}
		}
		
		if(bytes) {
			SecKeychainItemFreeAttributesAndData(NULL, bytes);
		}
    }
	
	if(storedItem)
		CFRelease(storedItem);
	
	
	if(result != errSecSuccess && result != errSecItemNotFound) {
		NSString *errorMessage = (__bridge_transfer NSString *)SecCopyErrorMessageString(result, NULL);
	
		if(error != NULL) {
			*error = [NSError errorWithDomain:StashKeychainError code:0 userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
		} else {
			qLog(@"Couldn't read object from keychain: %@", errorMessage);
		}
	}
	
	
	return authorizationObject;
}


- (BOOL)setAuthorizationToken:(NSString *)token withIdentifier:(NSNumber *)identifier error:(NSError **)error
{
	if(!token || !identifier) {
		qLog(@"Requires token and identifier: %@: %@", identifier, token);
		return FALSE;
	}
	
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{
		StashOAuthTokenKey : token,
		StashOAuthIdentifierKey : identifier
	} options:0 error:error];
	
	if(!jsonData) {
		qLog(@"Couldn't create jsonData from token and identifier: %@", error);
		return FALSE;
	}
	
	
	NSDictionary *authorizationAttributes = @{
		(id)kSecClass : (id)kSecClassGenericPassword,
		(id)kSecAttrService : StashOAuthKeychainIdentifier,
		(id)kSecValueData : jsonData,
		(id)kSecAttrLabel : @"GitHub OAuth token for Stash"
	};
	
	// First try adding the token
	OSStatus result = SecItemAdd((__bridge CFDictionaryRef)authorizationAttributes, NULL);
	
	if(result != errSecSuccess) {
		// If that returns an error then it's likely that it's because it
		// has already been set, so try to update the existing item
		result = SecItemUpdate((__bridge CFDictionaryRef)authorizationAttributes, (__bridge CFDictionaryRef)authorizationAttributes);
	}
	
	BOOL success = result == errSecSuccess;
	self.authenticated = success;
	
	if(success) {
		[self.httpClient setAuthorizationHeaderWithToken:token];
		[[NSNotificationCenter defaultCenter] postNotificationName:StashDidBecomeAuthorizedNotification object:nil];
		
		StashAccount *account = [self.issuesManager accountForIdentifier:identifier create:TRUE];
		self.issuesManager.currentAccount = account;
	} else {
		NSString *errorMessage = (__bridge_transfer NSString *)SecCopyErrorMessageString(result, NULL);
		
		if(error != NULL) {
			*error = [NSError errorWithDomain:StashKeychainError code:result userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
		} else
			qLog(@"There was an error storing the OAuth token in the Keychain: %@", errorMessage);
	}
	
	
	return success;
}


- (BOOL)removeAuthentication:(NSError **)error
{
	// Remove the authorization token from the keychain
	NSDictionary *matchingAttributes = @{
		(id)kSecClass : (id)kSecClassGenericPassword,
		(id)kSecAttrService : StashOAuthKeychainIdentifier
	};
	
	OSStatus result = SecItemDelete((__bridge CFDictionaryRef)matchingAttributes);
	BOOL success = result == errSecSuccess;
	
	if(success) {
		self.authenticated = FALSE;
		[[NSNotificationCenter defaultCenter] postNotificationName:StashDidResignAuthorizationNotification object:nil];
	} else {
		NSString *errorMessage = NSLocalizedString(@"Couldn't remove the authorization data from the keychain", @"Failed to remove from keychain");
		NSString *errorReason = (__bridge_transfer NSString *)SecCopyErrorMessageString(result, NULL);
		
		if(error != NULL) {
			*error = [NSError errorWithDomain:StashKeychainError code:result userInfo:@{
				NSLocalizedDescriptionKey : errorMessage,
				NSLocalizedFailureReasonErrorKey : errorReason
			}];
		} else
			qLog(@"%@: %@", errorMessage, errorReason);

	}
	
	return success;
}


@end
