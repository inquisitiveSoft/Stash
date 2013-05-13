#import "StashNetworkManager.h"
#import <Security/Security.h>

#import "AFNetworking.h"
#import "StashHTTPClient.h"
#import "qLog.h"


#define GITHUB_CLIENT_ID @"6e5a15de184327604f1d"
#define GITHUB_CLIENT_SECRET @"b33b8a9e8eddc2ac92db733621d0b013e85cfde5"


NSString * const StashRestRequestPath = @"StashRestRequestPath";
NSString * const StashRestRequestBody = @"StashRestRequestBody";
NSString * const StashRestRequestSuccessBlock = @"StashRestRequestSuccessBlock";
NSString * const StashRestRequestFailureBlock = @"StashRestRequestFailureBlock";
NSString * const StashRestRequestShouldUseBasicAuthentication = @"StashRestRequestShouldUseBasicAuthentication";

// Notifications
NSString * const StashDidBecomeAuthorizedNotification = @"StashDidBecomeAuthorizedNotification";
NSString * const StashDidResignAuthorizationNotification = @"StashDidResignAuthorizationNotification";


NSString * const StashRestRequestMethod = @"StashRestRequestMethod";
NSString * const StashRestRequestMethodGET = @"GET";
NSString * const StashRestRequestMethodPOST = @"POST";
NSString * const StashRestRequestMethodDELETE = @"DELETE";

NSString * const StashOAuthTokenKey = @"token";
NSString * const StashOAuthIdentifierKey = @"id";

NSString * const StashOAuthKeychainIdentifier = @"com.inquisitiveSoftware.Stash.OAuthToken";
NSString * const StashKeychainError = @"StashKeychainError";

static NSString *StashBase64EncodedStringFromString(NSString *string);



@interface StashNetworkManager ()

@property (strong) AFHTTPClient *httpClient;
@property (strong) NSData *username, *password;
@property (readwrite, getter = isAuthenticated) BOOL authenticated;

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
	NSURL *baseURL = [NSURL URLWithString:@"https://api.github.com/"];
	
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
}



#pragma mark - Authentication details

- (void)setUsername:(NSString *)username andPassword:(NSString *)password
{
//	self.username = XORData([username dataUsingEncoding:NSUTF8StringEncoding]);
//	self.password = XORData([password dataUsingEncoding:NSUTF8StringEncoding]);
	[self.httpClient setAuthorizationHeaderWithUsername:username password:password];
}


- (BOOL)setAuthorizationToken:(NSString *)token withIdentifier:(NSString *)identifier error:(NSError **)error
{
	if(!token || !identifier) {
		qLog(@"Requires token and identifier: %@: %@", identifier, token);
		return FALSE;
	}
	
	[self.httpClient setAuthorizationHeaderWithToken:token];
	
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
		self.username = nil;
		self.password = nil;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:StashDidBecomeAuthorizedNotification object:nil];
	} else {
		NSString *errorMessage = (__bridge_transfer NSString *)SecCopyErrorMessageString(result, NULL);
		
		if(error != NULL) {
			*error = [NSError errorWithDomain:StashKeychainError code:result userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
		} else
			qLog(@"There was an error storing the OAuth token in the Keychain: %@", errorMessage);
	}
	
	
	return success;
}



#pragma mark - Requesting and validating authorizations


- (void)requestOAuthToken:(AFRequestResultBlock)resultBlock
{
	if([self isAuthenticated]) {
		qLog(@"StashNetworkManager is already authenticated");
		return;
	}
	
	NSNumber *tokenIdentifier = [self authorizationIdentifier];
	
	if(tokenIdentifier) {
		[self requestExistingOAuthTokenForIdentifier:tokenIdentifier resultBlock:resultBlock];
	} else {
		[self requestNewOAuthToken:resultBlock];
	}
}


- (void)requestExistingOAuthTokenForIdentifier:(NSNumber *)tokenIdentifier resultBlock:(AFRequestResultBlock)resultBlock
{
	if(![tokenIdentifier isKindOfClass:[NSNumber class]]) {
		qError(@"Requires a tokenIdentifier");
		return;
	}
	
	__weak StashNetworkManager *networkManager = self;
	NSString *requestPath = [NSString stringWithFormat:@"authorizations/%@", tokenIdentifier];
	
	[self.httpClient getPath:requestPath parameters:@{
		@"client_id" : GITHUB_CLIENT_ID,
		@"client_secret" : GITHUB_CLIENT_SECRET
	} success:^(AFHTTPRequestOperation *httpOperation, id json) {
		BOOL success = FALSE;
		
		if([json isKindOfClass:[NSDictionary class]]) {
			NSString *authorizationToken = [json objectForKey:StashOAuthTokenKey];
			NSString *authorizationIdentifier = [json objectForKey:StashOAuthIdentifierKey];
			
			NSError *error = nil;
			printf("Found existing token for id: %ld", [authorizationIdentifier integerValue]);
			success = [networkManager setAuthorizationToken:authorizationToken withIdentifier:authorizationIdentifier error:&error];
			
			if(!success && error) {
				qLog(@"There was an error writing to the Keychain: %@", error);
			}
		}
		
		if(resultBlock) {
			resultBlock(success, nil);
		}
	} failure:^(AFHTTPRequestOperation *httpOperation, NSError *error) {
		if(httpOperation.response.statusCode == 404) {
			qLog(@"Recieved 404. It's likely the previous token was deleted from the applications list. Requesting a new token");
			[self requestNewOAuthToken:resultBlock];
		} else {
			qLog(@"failure: %@", httpOperation, error);
		}
	}];
}


- (void)requestNewOAuthToken:(AFRequestResultBlock)resultBlock
{
	__weak StashNetworkManager *networkManager = self;
	
	[self.httpClient postPath:@"authorizations" parameters:@{
		@"scopes" : @[@"user", @"public_repo", @"repo", @"notifications"],
		@"client_id" : GITHUB_CLIENT_ID,
		@"client_secret" : GITHUB_CLIENT_SECRET
	} success:^(AFHTTPRequestOperation *httpOperation, id json) {
		BOOL success = FALSE;
		
		if([json isKindOfClass:[NSDictionary class]]) {
			NSString *authorizationToken = [json objectForKey:StashOAuthTokenKey];
			NSString *authorizationIdentifier = [json objectForKey:StashOAuthIdentifierKey];
			
			NSError *error = nil;
			success = [networkManager setAuthorizationToken:authorizationToken withIdentifier:authorizationIdentifier error:&error];
			
			if(!success && error) {
				qLog(@"There was an error writing to the Keychain: %@", error);
			}
		}
		
		if(resultBlock) {
			resultBlock(success, nil);
		}
	} failure:^(AFHTTPRequestOperation *httpOperation, NSError *error) {
		AFJSONRequestOperation *operation = (AFJSONRequestOperation *)httpOperation;
		qLog(@"failure: %d", operation.hasAcceptableStatusCode);
	}];
}


- (BOOL)removeAuthentication:(NSError **)error
{
	// Remove the authorization token from the keychain
	// Leaving the tokens identifier to reuse it in the future, if possible
	NSDictionary *matchingAttributes = @{
		(id)kSecClass : (id)kSecClassGenericPassword,
		(id)kSecAttrService : StashOAuthKeychainIdentifier
	};
	
	OSStatus result = -1;
	NSString *tokenIdentifier = [self authorizationObjectForKey:StashOAuthIdentifierKey error:NULL];
	
	if(tokenIdentifier) {
		// If a tokenIdentifier exists, update the keychain items data to only include the indentifier
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{
			StashOAuthIdentifierKey : tokenIdentifier
		} options:0 error:error];
		
		if(jsonData) {
			NSDictionary *updatedAttributes = @{
				(id)kSecValueData : jsonData
			};

			result = SecItemUpdate((__bridge CFDictionaryRef)matchingAttributes, (__bridge CFDictionaryRef)updatedAttributes);
		} else
			qLog(@"Couldn't create json data from identifier: '%@' %@", tokenIdentifier, error);
	} else {
		// Otherwise attempt to remove the keychain item
		result = SecItemDelete((__bridge CFDictionaryRef)matchingAttributes);
	}
	
	
	BOOL success = result == errSecSuccess;
	
	if(success) {
		self.authenticated = FALSE;
		[[NSNotificationCenter defaultCenter] postNotificationName:StashDidResignAuthorizationNotification object:nil];
	} else {
		qLog(@"Couldn't remove the authorization data from the keychain: %@", error);
	}
	
	return success;
}



#pragma mark - 

- (void)performSync
{
}


- (void)pullIssues
{
	//		Get /user/repos
	//			for each get
	//				
	//				issues
	//		
	[self.httpClient getPath:@"/repos/inquisitiveSoft/Syml/issues" parameters:nil success:^(AFHTTPRequestOperation *operation, id json) {
		qLog(@"%@", json);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		qLog(@"Couldn't retrieve issues: %@", error);
	}];
}





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


@end
