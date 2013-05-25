#import "StashIssue.h"
#import "qLog.h"


@interface StashIssue ()

// Private interface goes here.

@end


@implementation StashIssue
@synthesize scoreForAbbreviation, maskForAbbreviation;


+ (NSDateFormatter *)dateFormatter
{
	static NSDateFormatter *__stashIssueDateFormatter = nil;
	
	static dispatch_once_t __createStashIssueDateFormatter;
	dispatch_once(&__createStashIssueDateFormatter, ^{
		__stashIssueDateFormatter = [[NSDateFormatter alloc] init];
		__stashIssueDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	});
	
	return __stashIssueDateFormatter;
}



+ (StashIssueState)stateFromString:(NSString *)stateString
{
	if([stateString isEqualToString:@"closed"])
		return StashIssueStateClosed;
	
	return StashIssueStateOpen;
}


+ (NSString *)stringFromState:(StashIssueState)issueState
{
	if(issueState == StashIssueStateClosed)
		return @"closed";
	
	return @"open";
}



- (void)setSyncedStateDictionary:(NSDictionary *)syncedStateDictionary
{
	NSData *syncedState = nil;
	
	if(syncedStateDictionary) {
		syncedState = [NSKeyedArchiver archivedDataWithRootObject:syncedStateDictionary];
	}
	
	self.syncedState = syncedState;
}


- (NSDictionary *)syncedStateDictionary
{
	NSData *syncedState = self.syncedState;
	if(!syncedState)
		return nil;
	
	NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:syncedState];
	return dictionary;
}





- (BOOL)updateIssueWithProperties:(NSDictionary *)issueProperties
{
	__block BOOL shouldUpdateValues = !self.identifier;
	shouldUpdateValues = TRUE;
	
	
	NSDictionary *syncedStateDictionary = self.syncedStateDictionary;
	
	if(syncedStateDictionary) {
		shouldUpdateValues = [syncedStateDictionary count];
		
		if(shouldUpdateValues) {
			[syncedStateDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
				if(![issueProperties[key] isEqual:value])
					shouldUpdateValues = FALSE;
			}];
		}
	}
	
	
	if(shouldUpdateValues) {
		self.identifier = issueProperties[@"id"];
		self.number = issueProperties[@"number"];
		self.title = issueProperties[@"title"];
		self.body = issueProperties[@"body"];
		self.stateValue = [StashIssue stateFromString:issueProperties[@"state"]];
		self.url = issueProperties[@"url"];
	}
	
	return shouldUpdateValues;
}





@end
