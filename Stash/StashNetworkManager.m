#import "StashNetworkManager.h"
#import <Security/Security.h>

#import "AFNetworking.h"
#import "qLog.h"



NSString * const StashRestRequestURL = @"StashRestRequestURL";
NSString * const StashRestRequestBody = @"StashRestRequestBody";
NSString * const StashRestRequestSuccessBlock = @"StashRestRequestSuccessBlock";
NSString * const StashRestRequestFailureBlock = @"StashRestRequestFailureBlock";
NSString * const StashRestRequestShouldUseBasicAuthentication = @"StashRestRequestShouldUseBasicAuthentication";

NSString * const StashRestRequestMethod = @"StashRestRequestMethod";
NSString * const StashRestRequestMethodGET = @"GET";
NSString * const StashRestRequestMethodPOST = @"POST";
NSString * const StashRestRequestMethodDELETE = @"DELETE";

NSString * const StashRestRequestOAuthTokenKey = @"token";
NSString * const StashRestRequestOAuthIdentifierKey = @"id";

NSString * const StashRestRequestOAuthKeychainIdentifier = @"com.inquisitiveSoftware.Stash.OAuthToken";
NSString * const StashRestRequestKeychainError = @"StashRestRequestKeychainError";

static NSString *StashBase64EncodedStringFromString(NSString *string);



@interface StashNetworkManager ()

@property (strong) NSData *username, *password;
@property (strong, nonatomic) NSString *baseURLString;
@property (readwrite, getter = isLinked) BOOL linked;

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
		self.baseURLString = @"https://api.github.com/";
	}
	
	return self;
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
		StashRestRequestOAuthTokenKey : token,
		StashRestRequestOAuthIdentifierKey : identifier
	} options:0 error:error];
	
	if(!jsonData) {
		qLog(@"Couldn't create jsonData from token and identifier: %@", error);
		return FALSE;
	}
	
	
	NSDictionary *authorizationAttributes = @{
		(id)kSecClass : (id)kSecClassGenericPassword,
		(id)kSecAttrService : StashRestRequestOAuthKeychainIdentifier,
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
	
	if(result == errSecSuccess) {
		self.username = nil;
		self.password = nil;
		self.linked = TRUE;
	} else {
		NSString *errorMessage = (__bridge_transfer NSString *)SecCopyErrorMessageString(result, NULL);
		
		if(error != NULL) {
			*error = [NSError errorWithDomain:StashRestRequestKeychainError code:result userInfo:@{
				NSLocalizedDescriptionKey : errorMessage
			}];
		} else
			qLog(@"There was an error storing the OAuth token in the Keychain: %@", errorMessage);
	}
	
	return (result == errSecSuccess);
}


- (NSString *)authorizationToken
{
	NSError *error = nil;
	NSString *authorizationToken = [self authorizationObjectForKey:StashRestRequestOAuthTokenKey error:&error];
	
	if(!authorizationToken) {
		qLog(@"There was an error reading the authorizationToken: '%@'", error);
	}
	
	return authorizationToken;
}


- (NSString *)authorizationObjectForKey:(NSString *)tokenKey error:(NSError **)error
{
	NSDictionary *matchingAttributes = @{
		(id)kSecClass : (id)kSecClassGenericPassword,
		(id)kSecAttrService : StashRestRequestOAuthKeychainIdentifier,
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
				authorizationObject = [tokenDictionary objectForKey:tokenKey ? : StashRestRequestOAuthTokenKey];
			}
		}
		
		if(bytes) {
			SecKeychainItemFreeAttributesAndData(NULL, bytes);
		}
    }
	
	if(storedItem)
		CFRelease(storedItem);
	
	
	if(result == errSecSuccess || result != errSecItemNotFound) {
		NSString *errorMessage = (__bridge_transfer NSString *)SecCopyErrorMessageString(result, NULL);
	
		if(error != NULL) {
			*error = [NSError errorWithDomain:StashRestRequestKeychainError code:0 userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
		} else {
			qLog(@"Couldn't read object from keychain: %@", errorMessage);
		}
	}
	
	
	return authorizationObject;
}


#pragma mark - 

- (void)requestOAuthTokens:(AFRequestResultBlock)resultBlock
{
	__weak StashNetworkManager *networkManager = self;
	
	[self postRequest:@{
		StashRestRequestURL : @"authorizations",
		
		StashRestRequestBody : @{
			@"scopes" : @[@"repo"],
			@"client_id" : @"6e5a15de184327604f1d",
			@"client_secret" : @"b33b8a9e8eddc2ac92db733621d0b013e85cfde5"
		},

		StashRestRequestSuccessBlock : ^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
			BOOL success = FALSE;
			if([json isKindOfClass:[NSDictionary class]]) {
				NSString *authorizationToken = [json objectForKey:StashRestRequestOAuthTokenKey];
				NSString *authorizationIdentifier = [json objectForKey:StashRestRequestOAuthIdentifierKey];
				
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


- (void)removeAuthentication:(AFRequestResultBlock)resultBlock
{
	NSError *error = nil;
	NSString *authorizationIdentifier = [self authorizationObjectForKey:StashRestRequestOAuthIdentifierKey error:&error];
	
	if(!authorizationIdentifier) {
		qLog(@"Couldn't retrieve the authorization id from the keychain: %@", error);
	} else {
		[self getRequest:@{
			StashRestRequestURL : [NSString stringWithFormat:@"authorizations/%@", authorizationIdentifier],
			
			StashRestRequestSuccessBlock : ^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
				// Remove the authorizations data from the keychain
				NSDictionary *matchingAttributes = @{
					(id)kSecClass : (id)kSecClassGenericPassword,
					(id)kSecAttrService : StashRestRequestOAuthKeychainIdentifier,
				};
				
				OSStatus result = SecItemDelete((__bridge CFDictionaryRef)matchingAttributes);
				BOOL success = result != errSecSuccess;
				
				if(success) {
					qLog(@"Couldn't remove the authorization data from the keychain: %@", error);
				}
				
				if(resultBlock) {
					resultBlock(success, nil);
				}
			},
			
			StashRestRequestFailureBlock : ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
				qLog(@"Failed to remove the authorization with the id: %@ error: %@", authorizationIdentifier, error);
				
				if(resultBlock) {
					resultBlock(FALSE, nil);
				}
			},
			
//			StashRestRequestShouldUseBasicAuthentication : @(TRUE)
		}];
	}
}



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
	
	qLog(@"'%@'", [urlRequest allHTTPHeaderFields]);
	
	AFRequestSuccessBlock successBlock = [attributes objectForKey:StashRestRequestSuccessBlock];
	AFRequestFailureBlock failureBlock = [attributes objectForKey:StashRestRequestFailureBlock];
	
	NSAssert(successBlock, @"Can't perform a request without a successBlock: %@", attributes);
	
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:successBlock failure:failureBlock];
	
	[operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
	
			qLog(@"redirect: %@", [request valueForHTTPHeaderField:@"Authorization"]);
            return request;

        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:request.URL cachePolicy:request.cachePolicy timeoutInterval:request.timeoutInterval];
        NSString *authValue = [NSString stringWithFormat:@"bearer %@", [self authorizationToken]];
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];

		qLog(@"redirect: %@", request);
        return  urlRequest;

    }];

	
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
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	if(!data)
		return nil;
	
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];

    for(NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
		for(NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
	
	NSString *result2 = [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
    return result2;
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
