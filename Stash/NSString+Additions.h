#import <Foundation/Foundation.h>


@interface NSString (SYMLAdditions)

- (NSRange)range;
- (SYMLTextRange *)textRange;

- (NSString *)substringWithUntestedRange:(NSRange)substringRange;
- (NSString *)normalizedString;

@end
