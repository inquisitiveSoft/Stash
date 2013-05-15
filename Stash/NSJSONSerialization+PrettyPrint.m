#import "NSJSONSerialization+PrettyPrint.h"


@implementation NSJSONSerialization (StashPrettyPrint)


+ (NSString *)prettyPrintJSONObject:(id)jsonObject
{
	if(jsonObject) {
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL];
		return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	}
	
	return nil;
}


@end
