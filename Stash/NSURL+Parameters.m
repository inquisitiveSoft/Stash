#import "NSURL+Parameters.h"
#import "RegexKitLite.h"


@implementation NSURL (StashParameters)


+ (NSDictionary *)dictionaryWithURLParametersFromString:(NSString *)urlString
{
	NSString *allParameters = [urlString stringByMatching:@"\\?([^#]*)" capture:1];
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	
	for(NSString *individualParameter in [allParameters componentsSeparatedByString:@"&"]) {
		NSString *key = [individualParameter stringByMatching:@"(.*)=(.*)" capture:1];
		NSString *value = [individualParameter stringByMatching:@"(.*)=(.*)" capture:2];
		
		if([key length] && [value length])
			[parameters setObject:value forKey:key];
	}
	
	return parameters;
}


@end
