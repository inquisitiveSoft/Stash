#import "NSString+Additions.h"


@implementation NSString (SYMLAdditions)


- (NSRange)range
{
	return NSMakeRange(0, [self length]);
}


- (SYMLTextRange *)textRange
{
	return [SYMLTextRange rangeFromLocation:0 withLength:[self length]];
}


- (NSString *)substringWithUntestedRange:(NSRange)substringRange
{
	return [self substringWithRange:NSRangeWithinString(self, substringRange)];
}


- (NSString *)normalizedString
{
	NSMutableString *convertedString = [[self lowercaseString] mutableCopy];
	CFRange stringRange = CFRangeMake(0, [self length]);
	CFStringTransform((CFMutableStringRef)convertedString, &stringRange, kCFStringTransformStripCombiningMarks, FALSE);
	return convertedString;
}


@end
