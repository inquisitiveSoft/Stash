#import "StashIssuesManager.h"


#import "NSJSONSerialization+PrettyPrint.h"
#import "NSDictionary+Verification.h"
#import "qLog.h"


NSString * const StashIssuesStoreFileName = @"Stash.issuesStore";

NSString * const StashCurrentAccountIdentifierKey = @"StashCurrentAccountURIKey";


@interface StashIssuesManager ()

@property (readwrite, retain) NSManagedObjectContext *persistanceSavingManagedObjectContext, *mainManagedObjectContext;
@property (strong) NSPersistentStoreCoordinator *persistanceStoreCoordinator;


@end



@implementation StashIssuesManager
@synthesize currentAccount = _currentAccount;


+ (id)sharedIssuesManager {
	static StashIssuesManager *__sharedIssuesManager = nil;
	static dispatch_once_t createSharedIssuesManager;
	dispatch_once(&createSharedIssuesManager, ^{
		__sharedIssuesManager = [[StashIssuesManager alloc] initSharedIssuesManager];
	});
	
	return __sharedIssuesManager;
}


- (id)init {
	NSAssert(FALSE, @"Treat the issues manager as a singleton. Call +[StashIssuesManager sharedIssuesManager] instead");
	return nil;
}


- (id)initSharedIssuesManager
{
	self = [super init];
	
	if(self) {
		[self setupManagedObjectContext];
	}
	
	return self;
}


- (void)setupManagedObjectContext
{
	// Get the users store URL
	NSError *error = nil;
	NSURL *applicationSupportURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:TRUE error:&error];
	
	if(!applicationSupportURL) {
		qError(@"Failed to create applicationSupportURL: %@", error);
	}
	
	NSURL *storeURL = [applicationSupportURL URLByAppendingPathComponent:StashIssuesStoreFileName];
	
	
	// Load the model, and create a persistanceStoreCoordinator with it
	NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	NSPersistentStoreCoordinator *persistanceStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
	self.persistanceStoreCoordinator = persistanceStoreCoordinator;
	
	error = nil;
	NSDictionary *storeOptions = @{
//		NSMigratePersistentStoresAutomaticallyOption : @(TRUE)
	};
	
	if(![persistanceStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&error]) {
		qLog(@"Failed to create a persistent store at %@ the URL: %@", storeURL, error);
	}
	
	NSManagedObjectContext *persistanceSavingManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	[persistanceSavingManagedObjectContext setPersistentStoreCoordinator:persistanceStoreCoordinator];
	self.persistanceSavingManagedObjectContext = persistanceSavingManagedObjectContext;
	
	NSManagedObjectContext *mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[mainManagedObjectContext setParentContext:persistanceSavingManagedObjectContext];
	
	self.mainManagedObjectContext = mainManagedObjectContext;
}


- (BOOL)save
{
	NSError *error = nil;
	if([self.mainManagedObjectContext save:&error]) {
		if(![self.persistanceSavingManagedObjectContext save:&error])
			qLog(@"The persistence saving managed object context failed to save: %@", error);
	} else
		qLog(@"Main managed object context failed to save: %@", error);
	
	return FALSE;
}



#pragma mark - Fetching Core Data objects


- (NSArray *)fetchObjectsOfEntityName:(NSString *)entityName matching:(id)predicate, ...
{
	if(![entityName length]) {
		qLog(@"Requires an entity name: %@", entityName);
		return nil;
	}
		
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
	
	if([predicate isKindOfClass:[NSString class]]) {
		va_list trailingArguments;
		va_start(trailingArguments, predicate);
		
		fetchRequest.predicate = [NSPredicate predicateWithFormat:predicate arguments:trailingArguments];
		
		va_end(trailingArguments);
	} else if([predicate isKindOfClass:[NSPredicate class]]) {
		fetchRequest.predicate = predicate;
	} else if(predicate) {
		qLog(@"Unexpected predicate. Expects a format string or a predicate. %@", predicate);
	}	
	
	NSError *error = nil;
	NSArray *result = [self.mainManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(!result && error) {
		qLog(@"%@", error);
	}
	
	return result;
}


- (id)objectOfEntityName:(NSString *)entityName matching:(id)predicate, ...
{
	if(![entityName length]) {
		qLog(@"Requires an entity name: %@", entityName);
		return nil;
	}
		
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
	
	if([predicate isKindOfClass:[NSString class]]) {
		va_list trailingArguments;
		va_start(trailingArguments, predicate);
		
		fetchRequest.predicate = [NSPredicate predicateWithFormat:predicate arguments:trailingArguments];
		
		va_end(trailingArguments);
	} else if([predicate isKindOfClass:[NSPredicate class]]) {
		fetchRequest.predicate = predicate;
	} else if(predicate) {
		qLog(@"Unexpected predicate. Expects a format string or a predicate. %@", predicate);
	}	
	
	NSError *error = nil;
	NSArray *result = [self.mainManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(!result && error) {
		qLog(@"%@", error);
	}
		
	if([result count] > 0)
		return [result objectAtIndex:0];
	
	return nil;
}



#pragma mark - Account management


- (void)setCurrentAccount:(StashAccount *)currentAccount
{
	_currentAccount = currentAccount;

	// Store a URI to the current account in the user defaults
	[[NSUserDefaults standardUserDefaults] setObject:currentAccount.identifier forKey:StashCurrentAccountIdentifierKey];
}


- (StashAccount *)currentAccount
{
	if(_currentAccount)
		return _currentAccount;
	
	NSNumber *currentAccountIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:StashCurrentAccountIdentifierKey];
	StashAccount *account = nil;
	
	// Look for an account with a matching identifier
	if(currentAccountIdentifier)
		account = [self objectOfEntityName:[StashAccount entityName] matching:@"identifier == %@", currentAccountIdentifier];
	
	// Otherwise look for any account
	if(!account)
		account = [self objectOfEntityName:[StashAccount entityName] matching:nil];
	
	return account;
}



- (StashAccount *)accountForTokenIdentifier:(NSNumber *)tokenIdentifier create:(BOOL)create
{
	StashAccount *account = [self objectOfEntityName:[StashAccount entityName] matching:@"tokenIdentifier = %@", tokenIdentifier];
	
	if(!account && create) {
		// Create a new account
		account = [StashAccount insertInManagedObjectContext:self.mainManagedObjectContext];
		account.tokenIdentifier = tokenIdentifier;
		[self.mainManagedObjectContext save:nil];
	}
	
	return account;
}


- (StashAccount *)accountForIdentifier:(NSNumber *)identifier
{
	StashAccount *account = [self objectOfEntityName:[StashAccount entityName] matching:@"identifier = %@", identifier];
	return account;
}


- (StashAccount *)accountForUsername:(NSString *)username
{
	return [self objectOfEntityName:[StashAccount entityName] matching:@"username == %@", username];
}


- (StashRepo *)repoForIdentfier:(NSNumber *)identifier account:(StashAccount *)account create:(BOOL)create
{
	StashRepo *repository = [self objectOfEntityName:[StashRepo entityName] matching:@"account = %@ AND identifier = %@", account, identifier];
	
	if(!repository && create) {
		// Create a new repository
		repository = [StashRepo insertInManagedObjectContext:self.mainManagedObjectContext];
		repository.identifier = identifier;
		repository.account = account;
	}
	
	return repository;
}


- (StashIssue *)issueForIdentfier:(NSNumber *)identifier repo:(StashRepo *)repo create:(BOOL)create existingIssue:(BOOL *)existingIssue
{
	StashIssue *issue = [self objectOfEntityName:[StashIssue entityName] matching:@"repo = %@ AND identifier = %@", repo, identifier];
	BOOL isExisting = TRUE;
	
	if(!issue && create) {
		// Create a new repository
		issue = [StashIssue insertInManagedObjectContext:self.mainManagedObjectContext];
		issue.identifier = identifier;
		issue.repo = repo;
		isExisting = FALSE;
	}
	
	if(existingIssue != NULL)
		*existingIssue = isExisting;
	
	return issue;
}




#pragma mark - Update content


- (NSArray *)updateReposforAccount:(StashAccount *)account withArray:(NSArray *)reposArray
{
	// Since we can't edit any of a repos info it's fine
	// to replace the existing set of repos entirely
	NSMutableArray *repos = [[NSMutableArray alloc] initWithCapacity:[reposArray count]];
	qLog(@"reposArray.count: %d", reposArray.count);
	
	for(NSDictionary *repoDictionary in reposArray) {
		NSError *error = nil;
		if([repoDictionary validatesAgainstExpectations:@{
			@"id"		: [NSNumber class],
			@"name"	: [NSString class],
		} error:&error]) {
			StashRepo *repo = [self repoForIdentfier:repoDictionary[@"id"] account:account create:TRUE];
			repo.name = repoDictionary[@"name"];
			[repos addObject:repo];
		} else if(error)
			qLog(@"repoDictionary failed validation: %@", error);
	}
	
	
	// Remove repos that aren't present in reposArray
	for(StashAccount *repo in account.repos) {
		if(![repos containsObject:repo]) {
			[self.mainManagedObjectContext deleteObject:repo];
		}
	}
	
	return repos;
}


- (NSArray *)updateIssuesforRepo:(StashRepo *)repo withArray:(NSArray *)issuesArray
{
	NSMutableArray *issues = [[NSMutableArray alloc] initWithCapacity:[issuesArray count]];
	NSMutableArray *issuesNeedingManualMerge = [[NSMutableArray alloc] init];
	
	NSDate *dateStampOfLastSync = repo.account.dateStampOfLastSync;
	
	if([issuesArray count]) {
		for(NSDictionary *issueProperties in issuesArray) {
			NSError *error = nil;
			if([issueProperties validatesAgainstExpectations:@{
				@"id"			: [NSNumber class],
				@"number"		: [NSNumber class],
				@"title"		: [NSString class],
				@"body"			: [NSString class],
				@"state"		: [NSString class],
				@"url"			: [NSString class],
				@"updated_at"	: [NSString class]
			} error:&error]) {
				BOOL existingIssue = FALSE;
				StashIssue *issue = [self issueForIdentfier:issueProperties[@"id"] repo:repo create:TRUE existingIssue:&existingIssue];
				
				NSString *dateString = [issueProperties objectForKey:@"updated_at"];
				NSDate *modificationDate = [[StashIssue dateFormatter] dateFromString:dateString];
				
				qLog(@"timeIntervalSinceDate: %d", [modificationDate timeIntervalSinceDate:dateStampOfLastSync]);
//				if([modificationDate timeIntervalSinceDate:dateStampOfLastSync]) {
//					qLog(@"<#%@#>", <#variable#>);
//				}
				
//				if(![issue updateIssueWithProperties:issueProperties])
//					[issuesNeedingManualMerge addObject:issue];
				
				[issues addObject:issue];
			} else if(error)
				qLog(@"issueProperties dictionary failed validation: %@", error);
		}
	}
	
	return issues;
}


@end
