#import <Foundation/Foundation.h>

#import "StashAccount.h"
#import "StashRepository.h"
#import "StashIssue.h"
#import "StashMilestone.h"
#import "StashLabel.h"
#import "StashUsers.h"


@interface StashIssuesManager : NSObject

+ (id)sharedIssuesManager;

@property (readonly, retain, nonatomic) NSManagedObjectContext *persistanceSavingManagedObjectContext, *mainManagedObjectContext;
@property (strong, nonatomic) StashAccount *currentAccount;

- (StashAccount *)accountForIdentifier:(NSNumber *)identifier create:(BOOL)create;
- (StashAccount *)accountForUsername:(NSString *)username;


- (void)updateAccountDetailsWithJSON:(NSDictionary *)json;


@end
