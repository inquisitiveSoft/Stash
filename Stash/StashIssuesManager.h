#import <Foundation/Foundation.h>

#import "StashAccount.h"
#import "StashRepo.h"
#import "StashIssue.h"
#import "StashMilestone.h"
#import "StashLabel.h"
#import "StashUsers.h"


extern NSString * const StashCurrentAccountDidChange;


@interface StashIssuesManager : NSObject

+ (StashIssuesManager *)sharedIssuesManager;


@property (readonly, retain, nonatomic) NSManagedObjectContext *persistanceSavingManagedObjectContext, *mainManagedObjectContext;

@property (strong, nonatomic) StashAccount *currentAccount;


- (BOOL)save;

- (StashAccount *)accountForTokenIdentifier:(NSNumber *)authorizationIdentifier create:(BOOL)create;
- (StashAccount *)accountForIdentifier:(NSNumber *)identifier;
- (StashAccount *)accountForUsername:(NSString *)username;
- (StashRepo *)repoForIdentfier:(NSNumber *)identifier account:(StashAccount *)account create:(BOOL)create;

- (NSArray *)fetchObjectsOfEntityName:(NSString *)entityName matching:(id)predicate, ...;
- (NSArray *)fetchObjectsOfEntityName:(NSString *)entityName matching:(id)predicate arguments:(va_list)predicateArguments sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)fetchObjectsOfEntityName:(NSString *)entityName matching:(NSString *)predicateString argumentArray:(NSArray *)predicateArguments sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)fetchObjectsOfEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors;

- (id)objectOfEntityName:(NSString *)entityName matching:(id)predicate, ...;

- (NSArray *)updateReposforAccount:(StashAccount *)account withArray:(NSArray *)reposArray;
- (NSArray *)updateIssuesforRepo:(StashRepo *)repo withArray:(NSArray *)issuesArray;

@end
