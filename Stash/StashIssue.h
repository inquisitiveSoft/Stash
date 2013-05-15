#import "_StashIssue.h"


typedef NS_ENUM(NSUInteger, StashIssueState) {
	StashIssueStateOpen,
	StashIssueStateClosed
};


@interface StashIssue : _StashIssue {}

+ (NSDateFormatter *)dateFormatter;
+ (StashIssueState)stateFromString:(NSString *)stateString;
+ (NSString *)stringFromState:(StashIssueState)issueState;

@property (assign, nonatomic) NSDictionary *syncedStateDictionary;

- (BOOL)updateIssueWithProperties:(NSDictionary *)issueProperties;


@end
