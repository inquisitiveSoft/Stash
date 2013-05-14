#import "StashIssuesManager.h"
#import "qLog.h"


NSString * const StashIssuesStoreFileName = @"StashIssuesStoreFileName";


@interface StashIssuesManager ()

@property (readwrite, retain) NSManagedObjectContext *persistanceSavingManagedObjectContext, *mainManagedObjectContext;


@end



@implementation StashIssuesManager


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


- (StashAccount *)accountForIdentifier:(NSNumber *)identifier create:(BOOL)create
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@" argumentArray:@[identifier]];
	StashAccount *account = [self objectOfEntityName:[StashAccount entityName] matchingPredicate:predicate];
	
	if(!account && create) {
		// Create a new account
		account = [StashAccount insertInManagedObjectContext:self.mainManagedObjectContext];
		account.identifier = identifier;
	}
	
	return account;
}


- (StashAccount *)accountForUsername:(NSString *)username
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@" argumentArray:@[username]];
	return [self objectOfEntityName:[StashAccount entityName] matchingPredicate:predicate];
}


- (id)objectOfEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
	fetchRequest.predicate = predicate;
	
	NSError *error = nil;
	NSArray *result = [self.mainManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(!result && error) {
		qLog(@"%@", error);
	}
	
	if([result count] > 0)
		return [result objectAtIndex:0];
	
	return nil;
}



- (void)updateAccountDetailsWithJSON:(NSDictionary *)json;
{
	qLog(@"\n%@", json);
	NSNumber *identifier = [json objectForKey:@"id"];
	
	if([identifier isKindOfClass:[NSNumber class]]) {
		[self accountForIdentifier:identifier create:FALSE];
	}
}


@end
