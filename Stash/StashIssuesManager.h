#import <Foundation/Foundation.h>

#import "StashAccount.h"
#import "StashRepo.h"
#import "StashIssue.h"
#import "StashMilestone.h"
#import "StashLabel.h"
#import "StashUsers.h"


@interface StashIssuesManager : NSObject

+ (id)sharedIssuesManager;

@property (readonly, retain, nonatomic) NSManagedObjectContext *persistanceSavingManagedObjectContext, *mainManagedObjectContext;
@property (strong, nonatomic) StashAccount *currentAccount;

- (BOOL)save;

- (StashAccount *)accountForTokenIdentifier:(NSNumber *)authorizationIdentifier create:(BOOL)create;
- (StashAccount *)accountForIdentifier:(NSNumber *)identifier;
- (StashAccount *)accountForUsername:(NSString *)username;

- (void)updateReposforAccount:(StashAccount *)account withArray:(NSArray *)newRepos;

@end
