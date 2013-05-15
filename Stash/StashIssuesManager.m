#import "StashIssuesManager.h"
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



#pragma mark - Nice fetching for Core Data


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


- (void)updateReposforAccount:(StashAccount *)account withArray:(NSArray *)newRepos
{
	// Since we can't edit any of a repos info
	// just replace the existing set entirely
	NSMutableSet *newRepoIdentifiers = [[NSMutableSet alloc] initWithCapacity:[newRepos count]];
	
	for(NSDictionary *repoDictionary in newRepos) {
		NSNumber *identifier = repoDictionary[@"id"];
		
		if(!identifier) {
			qLog(@"Couldn't read the repos id from the dictionary: %@", repoDictionary);
			continue;
		} else
			[newRepoIdentifiers addObject:identifier];
		
		StashRepo *repo = [self repoForIdentfier:identifier create:TRUE];
		repo.account = account;
		repo.name = repoDictionary[@"name"];
	}
	
	
	// Remove repos that aren't present in newRepos
	for(StashAccount *repo in account.repos) {
		NSNumber *identifier = repo.identifier;
		
		if(!identifier || ![newRepoIdentifiers containsObject:identifier]) {
			[self.mainManagedObjectContext deleteObject:repo];
		}
	}
}



- (StashRepo *)repoForIdentfier:(NSNumber *)identifier create:(BOOL)create
{
	StashRepo *repository = [self objectOfEntityName:[StashRepo entityName] matching:@"identifier = %@", identifier];
	
	if(!repository && create) {
		// Create a new repository
		repository = [StashRepo insertInManagedObjectContext:self.mainManagedObjectContext];
		repository.identifier = identifier;
	}
	
	return repository;
}


@end
