#import "AFHTTPRequestOperation+StashAdditions.h"


@implementation AFHTTPRequestOperation (StashAdditions)


+ (NSDateFormatter *)dateFormatter
{
	static NSDateFormatter *__requestOperationDateFormatter = nil;
	
	static dispatch_once_t __createRequestOperationDateFormatter;
	dispatch_once(&__createRequestOperationDateFormatter, ^{
		__requestOperationDateFormatter = [[NSDateFormatter alloc] init];
		__requestOperationDateFormatter.dateFormat = @"EEE, d MMM yyyy HH:mm:ss zzz";
	});
	
	return __requestOperationDateFormatter;
}


- (NSDate *)dateStamp
{
	// Expects a date with the format:	Tue, 14 May 2013 11:13:06 GMT
	NSString *dateString = [self.response.allHeaderFields objectForKey:@"Date"];
	NSDate *date = nil;
	
	if(dateString.length)
		date = [[AFHTTPRequestOperation dateFormatter] dateFromString:dateString];
	
	return date;
}


- (NSDate *)dateOfLastModification
{
	// Expects a date with the format:	Tue, 14 May 2013 11:13:06 GMT
	NSString *dateString = [self.response.allHeaderFields objectForKey:@"Last-Modified"];
	NSDate *date = nil;
	
	if(dateString.length)
		date = [[AFHTTPRequestOperation dateFormatter] dateFromString:dateString];
	
	return date;
}


@end
