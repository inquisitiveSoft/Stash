#import "AFHTTPRequestOperation.h"

@interface AFHTTPRequestOperation (StashAdditions)

+ (NSDateFormatter *)dateFormatter;

- (NSDate *)dateStamp;
- (NSDate *)dateOfLastModification;

- (NSDictionary *)linkElements;

@end
