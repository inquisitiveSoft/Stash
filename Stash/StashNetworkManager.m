#import "StashNetworkManager.h"
#import <Security/Security.h>

#import "AFNetworking.h"
#import "qLog.h"


#define GITHUB_CLIENT_ID @"6e5a15de184327604f1d"
#define GITHUB_CLIENT_SECRET @"b33b8a9e8eddc2ac92db733621d0b013e85cfde5"


NSString * const StashRestRequestURL = @"StashRestRequestURL";
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

@property (strong) NSData *username, *password;
@property (strong, nonatomic) NSString *baseURLString;
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
	self.baseURLString = @"https://api.github.com/";
	self.authenticated = [[self authorizationToken] length] > 0;
}



#pragma mark - Authentication details

- (void)setUsername:(NSString *)username andPassword:(NSString *)password
{
	self.username = XORData([username dataUsingEncoding:NSUTF8StringEncoding]);
	self.password = XORData([password dataUsingEncoding:NSUTF8StringEncoding]);
}


- (BOOL)setAuthorizationToken:(NSString *)token withIdentifier:(NSString *)identifier error:(NSError **)error
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
	
	if(success) {
		self.username = nil;
		self.password = nil;
		self.authenticated = TRUE;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:StashDidBecomeAuthorizedNotification object:nil];
	} else {
		self.authenticated = FALSE;
		
		NSString *errorMessage = (__bridge_transfer NSString *)SecCopyErrorMessageString(result, NULL);
		
		if(error != NULL) {
			*error = [NSError errorWithDomain:StashKeychainError code:result userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
		} else
			qLog(@"There was an error storing the OAuth token in the Keychain: %@", errorMessage);
	}
	
	
	return success;
}


- (NSString *)authorizationToken
{
	NSError *error = nil;
	NSString *authorizationToken = [self authorizationObjectForKey:StashOAuthTokenKey error:&error];
	
	if(!authorizationToken && error) {
		qLog(@"There was an error reading the authorizationToken: '%@'", error);
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
	
	[self postRequest:@{
		StashRestRequestURL : [NSString stringWithFormat:@"authorizations/%@", tokenIdentifier],
		
		StashRestRequestBody : @{
			@"client_id" : GITHUB_CLIENT_ID,
			@"client_secret" : GITHUB_CLIENT_SECRET
		},

		StashRestRequestSuccessBlock : ^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
			BOOL success = FALSE;
			if([json isKindOfClass:[NSDictionary class]]) {
				NSString *authorizationToken = [json objectForKey:StashOAuthTokenKey];
				NSString *authorizationIdentifier = [json objectForKey:StashOAuthIdentifierKey];
				
				NSError *error = nil;
				qLog(@"existing token for id: %@", authorizationIdentifier);
				success = [networkManager setAuthorizationToken:authorizationToken withIdentifier:authorizationIdentifier error:&error];
				
				if(!success && error) {
					qLog(@"There was an error writing to the Keychain: %@", error);
				}
			}
			
			if(resultBlock) {
				resultBlock(success, nil);
			}
		},
		
		StashRestRequestFailureBlock : ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
			qLog(@"failure: %@, %@, %@, %@", request, response, error, JSON);
		},
		
		StashRestRequestShouldUseBasicAuthentication : @(TRUE)
	}];
}


- (void)requestNewOAuthToken:(AFRequestResultBlock)resultBlock
{
	__weak StashNetworkManager *networkManager = self;
	
	[self postRequest:@{
		StashRestRequestURL : @"authorizations",
		
		StashRestRequestBody : @{
			@"scopes" : @[@"user", @"public_repo", @"repo", @"notifications"],
			@"client_id" : GITHUB_CLIENT_ID,
			@"client_secret" : GITHUB_CLIENT_SECRET
		},

		StashRestRequestSuccessBlock : ^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
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
		},
		
		StashRestRequestFailureBlock : ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
			qLog(@"failure: %@, %@, %@, %@", request, response, error, JSON);
		},
		
		StashRestRequestShouldUseBasicAuthentication : @(TRUE)
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


- (void)getRequest:(NSDictionary *)attributes
{
	[self performRequest:attributes httpMethod:StashRestRequestMethodGET];
}


- (void)postRequest:(NSDictionary *)attributes
{
	[self performRequest:attributes httpMethod:StashRestRequestMethodPOST];
}


- (void)deleteRequest:(NSDictionary *)attributes
{
	[self performRequest:attributes httpMethod:StashRestRequestMethodDELETE];
}



- (void)performRequest:(NSDictionary *)attributes httpMethod:(NSString *)httpMethod
{
	id potentialURL = [attributes objectForKey:StashRestRequestURL];
	
	if([potentialURL isKindOfClass:[NSURL class]])
		potentialURL = [potentialURL absoluteString];
	
	NSURL *url = nil;
	if([potentialURL isKindOfClass:[NSString class]]) {
		NSString *urlString = [NSString stringWithFormat:@"%@%@", self.baseURLString, potentialURL];
		url = [NSURL URLWithString:urlString];
	}
		
	NSAssert(url, @"StashRestRequestURL is expected to contain either a NSURL or NSString representation of a url: %@", attributes);
	
	
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	urlRequest.HTTPMethod = httpMethod ? : StashRestRequestMethodGET;
	urlRequest.HTTPShouldHandleCookies = FALSE;
	
	id requestBody = [attributes objectForKey:StashRestRequestBody];
	
	if(requestBody && ![requestBody isKindOfClass:[NSData class]]) {
		// 
		if([requestBody respondsToSelector:@selector(dataUsingEncoding:)]) {
			requestBody = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
		} else if([requestBody isKindOfClass:[NSArray class]] || [requestBody isKindOfClass:[NSDictionary class]]) {
			NSError *error = nil;
			requestBody = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&error];
			
			if(!requestBody) {
				qLog(@"There was an error parsing the %@ request body to JSON data. %@ %@", error, attributes);
			}
		} else {
			requestBody = nil;
		}
	}
	
	urlRequest.HTTPBody = requestBody;
	
	if(![[attributes objectForKey:StashRestRequestShouldUseBasicAuthentication] boolValue]) {
		// Use OAuth by default
		NSString *authorizationToken = [NSString stringWithFormat:@"token %@", [self authorizationToken]];
		[urlRequest setValue:authorizationToken forHTTPHeaderField:@"Authorization"];
	} else {
		// Add the basic authentication header
		[urlRequest setValue:[self basicAuthenticationHeader] forHTTPHeaderField:@"Authorization"];
	}


	[urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//	[urlRequest setValue:@"en-gb" forHTTPHeaderField:@"Accept-Language"];
//	[urlRequest setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
	
	AFRequestSuccessBlock successBlock = [attributes objectForKey:StashRestRequestSuccessBlock];
	AFRequestFailureBlock failureBlock = [attributes objectForKey:StashRestRequestFailureBlock];
	NSAssert(successBlock, @"Can't perform a request without a successBlock: %@", attributes);
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:successBlock failure:failureBlock];
	[operation start];
}


- (NSString *)basicAuthenticationHeader
{
	NSString *username = [[NSString alloc] initWithData:XORData(self.username) encoding:NSUTF8StringEncoding];
	NSString *password = [[NSString alloc] initWithData:XORData(self.password) encoding:NSUTF8StringEncoding];
	
	NSString *authenticationString = StashBase64EncodedStringFromString([NSString stringWithFormat:@"%@:%@", username, password]);
	authenticationString = [NSString stringWithFormat:@"Basic %@", authenticationString];
	
	return authenticationString;
}



static NSString *StashBase64EncodedStringFromString(NSString *string)
{
	NSData *dataToEncode = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSString *result = nil;
	
	if([dataToEncode length]) {
		CFErrorRef error = nil;
		SecTransformRef base64Transform = SecEncodeTransformCreate(kSecBase64Encoding, &error);
		
		if(base64Transform) {
			if(SecTransformSetAttribute(base64Transform, kSecTransformInputAttributeName, (__bridge CFDataRef)dataToEncode, &error)) {
				CFDataRef resultingData = SecTransformExecute(base64Transform, &error);
				
				if(resultingData) {
					result = [[NSString alloc] initWithData:(__bridge_transfer NSData *)resultingData encoding:NSASCIIStringEncoding];
				} else
					NSLog(@"The base64 transform didn't return any data: %@", error);
			} else
				NSLog(@"There was an error setting the input attribute on the base64 attribute: %@", error);
			
			CFRelease(base64Transform);
		} else
			NSLog(@"There was an error creating a base64 transform: %@", error);
	} else
		NSLog(@"The StashBase64EncodedStringFromString was called with an empty string");
	
	return result ? : @"";
}



NSData *XORData(NSData *data)
{
	//
	// This helps avoid storing passwords on the heap in plaintext
	//
	// From https://code.google.com/p/gdata-objectivec-client/source/browse/trunk/Source/BaseClasses/GDataServiceBase.m#52
	// http://www.apache.org/licenses/LICENSE-2.0
	//
	
	NSMutableData *mutableData = [data mutableCopy];
	
	if(data) {
		NSUInteger length = [mutableData length];
		unsigned char *mutableBytes = [mutableData mutableBytes];
		const unsigned char theXORValue = 0x95; // 0x95 = 0xb10010101
		
		for(NSUInteger cursor = 0; cursor < length; cursor++) {
			mutableBytes[cursor] ^= theXORValue;
		}
	}
	
	return mutableData;
}


@end
