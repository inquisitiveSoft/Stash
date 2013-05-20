#import "StashNetworkManager.h"

#import <Security/Security.h>
#import "RegexKitLite.h"

#import "AFNetworking.h"
#import "StashIssuesManager.h"
#import "StashHTTPClient.h"
#import "qLog.h"

#import "AFHTTPRequestOperation+StashAdditions.h"
#import "NSURLRequest+TokenIdentifier.h"
#import "NSURL+Parameters.h"
#import "NSJSONSerialization+PrettyPrint.h"


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

@property (strong) StashHTTPClient *httpClient;
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
	
	NSNumber *authorizationIdentifier = [self authorizationIdentifier];
	NSString *authorizationToken = [self authorizationToken];
	
	if([authorizationToken length]) {
		[httpClient setAuthorizationHeaderWithToken:authorizationToken];
		httpClient.currentTokenIdentifier = authorizationIdentifier;
		
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


- (NSString *)apiPathForKey:(NSString *)apiKey
{
	if(![apiKey length])
		return nil;
	
	NSString *originalPath = [self.api objectForKey:apiKey];
	
	//	^https://api.github.com/([A-Za-z0-9/_-]*)(\{\?(.*)\})?
	NSString *pattern = [NSString stringWithFormat:@"^%@([A-Za-z0-9/_-]*)(\\{\\?(.*)\\})?", StashDefaultGitHubAPILocation];
	NSString *apiPath = [originalPath stringByMatching:pattern capture:1];
		
	return apiPath;
}


- (NSDictionary *)defaultParametersForAPIKey:(NSString *)apiKey
{
	if(![apiKey length])
		return nil;
	
	NSString *originalPath = [self.api objectForKey:apiKey];
	NSString *pattern = [NSString stringWithFormat:@"^%@([A-Za-z0-9/_-]*)(\\{\\?(.*)\\})?", StashDefaultGitHubAPILocation];
	NSArray *validParameters = [[originalPath stringByMatching:pattern capture:3] componentsSeparatedByString:@","];
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	
	// If the allowed parameters include the per_page then set it at 100
	if([validParameters containsObject:StashGitHubPerPageParameter]) {
		parameters[StashGitHubPerPageParameter] = @(10);
	}
		
	return parameters;
}


- (StashAccount *)accountForOperation:(AFHTTPRequestOperation *)operation
{
	NSNumber *tokenIdentifier = operation.request.tokenIdentifier;
	StashAccount *account = [self.issuesManager accountForTokenIdentifier:tokenIdentifier create:TRUE];
	
	return account;
}



#pragma mark - Requesting and validating authorizations


- (void)requestOAuthTokenForUsername:(NSString *)username password:(NSString *)password success:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock
{
	if([self isAuthenticated]) {
		qLog(@"StashNetworkManager is already authenticated");
		return;
	}
	
	if([username length] == 0 || [password length] == 0) {
		qLog(@"Requires both a username (%@) and password (%@)", username, password);
	}
	
	[self.httpClient setAuthorizationHeaderWithUsername:username password:password];
	NSNumber *existingTokenIdentifier = [self.issuesManager accountForUsername:username].tokenIdentifier;
	
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
			qLog(@"Recieved 404 while looking for an existing token: %@. It's likely the previous token was deleted from the applications list. Requesting a new token", tokenIdentifier);
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
		hasChangesToPull = TRUE;
		
		if(hasChangesToPull) {
			// Update the current account
			StashAccount *account = [self accountForOperation:operation];
			[account updateAccountDetailsWithDictionary:response];
			self.issuesManager.currentAccount = account;
			
			[self pullChanges:^(AFHTTPRequestOperation *operation, id responseObject) {
				// Pull changes
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				
			}];
		}
		
		currentAccount.dateStampOfLastSync = [operation dateStamp];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
	}];
}


- (void)pullChanges:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock
{
	AFOperationGroup *group = [[AFOperationGroup alloc] initWithCompletionBlock:^(NSArray *operations) {
//		NSArray *repos = [self.issuesManager fetchObjectsOfEntityName:[StashRepo entityName] matching:nil];
//		qLog(@"repos: %d", repos.count);
//		
//		for(StashRepo *repo in repos) {
//			printf("%s\n", [[NSString stringWithFormat:@"	%@", repo.name] UTF8String]);
//			
//			for(StashIssue *issue in repo.issues) {
//				printf("%s\n", [[NSString stringWithFormat:@"		#%@ %@", issue.number, issue.title] UTF8String]);
//			}
//		}
	}];

	[self requestReposWithParameters:nil previousContent:nil group:group success:^(AFHTTPRequestOperation *operation, NSArray *combinedContent) {
		// Otherwise parse the combined content
		NSArray *repos = [self.issuesManager updateReposforAccount:[self accountForOperation:operation] withArray:combinedContent];
		
		for(StashRepo *repo in repos) {
			// Request the open issues
//			[self requestMilestonesForRepo:repo success:successBlock failure:failureBlock];
//			[self requestLabelsForRepo:repo success:successBlock failure:failureBlock];
//			[self requestUsersForRepo:repo success:successBlock failure:failureBlock];
			[self requestIssuesForRepo:repo group:group success:successBlock failure:failureBlock];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		qLog(@"Failed to load repos: %@ - %@", operation.request.URL, error);
		
		if(failureBlock) {
			failureBlock(operation, error);
		}
	}];
}


- (void)requestReposWithParameters:(NSDictionary *)parameters previousContent:(id)previousContent group:(AFOperationGroup *)group success:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock
{
	// Request repos
	NSString *key = @"current_user_repositories_url";
	NSString *path = [self apiPathForKey:key];
	parameters = parameters ? : [self defaultParametersForAPIKey:key];
	
	[self.httpClient getPath:path parameters:parameters attachedObject:previousContent group:group success:^(AFHTTPRequestOperation *operation, NSArray *reposArray) {
		// Append the previous pages content with the newly loaded content
		NSArray *combinedContent = reposArray;
		NSArray *previousContent = operation.request.attachedObject;
		
		if(previousContent)
			combinedContent = [previousContent arrayByAddingObjectsFromArray:combinedContent];
		
		// If the returned header contains a 'next' url then load that content
		NSString *nextLinkURLString = [operation linkElements][@"next"];
		
		if([nextLinkURLString length]) {
			NSDictionary *parsedParameters = [NSURL dictionaryWithURLParametersFromString:nextLinkURLString];
			[self requestReposWithParameters:parsedParameters previousContent:combinedContent group:group success:successBlock failure:failureBlock];
		} else {
			if(successBlock) {
				successBlock(operation, combinedContent);
			}
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if(failureBlock) {
			failureBlock(operation, error);
		}
	}];
}





#pragma mark - Requesting issues


- (void)requestIssuesForRepo:(StashRepo *)repo group:(AFOperationGroup *)group success:(AFRequestSuccessBlock)successBlock failure:(AFRequestFailureBlock)failureBlock
{
	// Load the open issues for the repo
	NSDictionary *openPatameters = @{ @"state" : @"open" };
	[self requestIssuesForRepo:repo withParameters:openPatameters previousContent:nil group:group success:^(AFHTTPRequestOperation *operation, NSArray *issuesArray) {
		// Load the closed issues for the repo
		NSDictionary *closedPatameters = @{ @"state" : @"closed" };
		[self requestIssuesForRepo:repo withParameters:closedPatameters previousContent:issuesArray group:group success:^(AFHTTPRequestOperation *operation, NSArray *issuesArray) {
			NSArray *issues = [self.issuesManager updateIssuesforRepo:repo withArray:issuesArray];
			
//			qLog(nil);
//			for(StashIssue *issue in issues) {
//				printf("%s\n", [[NSString stringWithFormat:@"	%@	#%@ %@", issue.repo.name, issue.number, issue.title] UTF8String]);
//			}
			
			if(successBlock) {
				successBlock(operation, issues);
			}
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			
		}];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		// A 410 error signifies that the repo has issues switched off
		if(operation.response.statusCode != 410) {
			qLog(@"Couldn't retrieve issues: %@", error);
			
			if(failureBlock) {
				failureBlock(operation, error);
			}
		}
	}];
}


- (void)requestIssuesForRepo:(StashRepo *)repo withParameters:(NSDictionary *)parameters previousContent:(id)previousContent group:(AFOperationGroup *)group success:(AFRequestSuccessBlock)successBlock failure:(AFRequestSuccessBlock)failureBlock
{	
	NSString *path = [NSString stringWithFormat:@"repos/%@/%@/issues", repo.account.username, repo.name];
	
	[self.httpClient getPath:path parameters:parameters attachedObject:previousContent group:(AFOperationGroup *)group success:^(AFHTTPRequestOperation *operation, NSArray *reposArray) {
		// Append the previous pages content with the newly loaded content
		NSArray *combinedContent = reposArray;
		NSArray *previousContent = operation.request.attachedObject;
		
		if(previousContent)
			combinedContent = [previousContent arrayByAddingObjectsFromArray:combinedContent];
		
		// If the returned header contains a 'next' url then continue to load that content
		NSString *nextLinkURLString = [operation linkElements][@"next"];
		
		if([nextLinkURLString length]) {
			NSDictionary *parsedParameters = [NSURL dictionaryWithURLParametersFromString:nextLinkURLString];
			[self requestIssuesForRepo:repo withParameters:parsedParameters previousContent:combinedContent group:group success:successBlock failure:failureBlock];
		} else {
			// Otherwise parse the combined content
			if(successBlock) {
				successBlock(operation, combinedContent);
			}
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if(failureBlock) {
			failureBlock(operation, error);
		}
	}];
}




#pragma mark - Storing authorization tokens in the keychain


- (NSString *)authorizationToken
{
	NSError *error = nil;
	NSString *authorizationToken = [self authorizationObjectForKey:StashOAuthTokenKey error:&error];
	
	if(!authorizationToken && error) {
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
		self.httpClient.currentTokenIdentifier = identifier;
		[self.httpClient setAuthorizationHeaderWithToken:token];
		[[NSNotificationCenter defaultCenter] postNotificationName:StashDidBecomeAuthorizedNotification object:nil];
		
		StashAccount *account = [self.issuesManager accountForTokenIdentifier:identifier create:TRUE];
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
	
	OSStatus result = -1;
	
	@try {
		result = SecItemDelete((__bridge CFDictionaryRef)matchingAttributes);
	}
	
	@catch (NSException *exception) {
		qLog(@"SecItemDelete crashed");
	}
	
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
