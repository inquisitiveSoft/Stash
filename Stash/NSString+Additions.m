#import "NSString+Additions.h"


@implementation NSString (StashAdditions)


- (NSString *)normalizedString
{
	NSMutableString *convertedString = [[self lowercaseString] mutableCopy];
	CFRange stringRange = CFRangeMake(0, [self length]);
	CFStringTransform((CFMutableStringRef)convertedString, &stringRange, kCFStringTransformStripCombiningMarks, FALSE);
	return convertedString;
}


@end
