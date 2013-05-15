#import "AFHTTPRequestOperation.h"

@interface AFHTTPRequestOperation (StashAdditions)

- (NSDate *)dateStamp;
- (NSDate *)dateOfLastModification;

- (NSDictionary *)linkElements;

@end
