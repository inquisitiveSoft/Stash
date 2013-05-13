// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashAccount.m instead.

#import "_StashAccount.h"

const struct StashAccountAttributes StashAccountAttributes = {
	.avatarURL = @"avatarURL",
	.identifier = @"identifier",
	.timeOfLastSync = @"timeOfLastSync",
	.username = @"username",
};

const struct StashAccountRelationships StashAccountRelationships = {
	.repositories = @"repositories",
};

const struct StashAccountFetchedProperties StashAccountFetchedProperties = {
};

@implementation StashAccountID
@end

@implementation _StashAccount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StashAccount" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StashAccount";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StashAccount" inManagedObjectContext:moc_];
}

- (StashAccountID*)objectID {
	return (StashAccountID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic avatarURL;






@dynamic identifier;



- (int64_t)identifierValue {
	NSNumber *result = [self identifier];
	return [result longLongValue];
}

- (void)setIdentifierValue:(int64_t)value_ {
	[self setIdentifier:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveIdentifierValue {
	NSNumber *result = [self primitiveIdentifier];
	return [result longLongValue];
}

- (void)setPrimitiveIdentifierValue:(int64_t)value_ {
	[self setPrimitiveIdentifier:[NSNumber numberWithLongLong:value_]];
}





@dynamic timeOfLastSync;






@dynamic username;






@dynamic repositories;

	
- (NSMutableSet*)repositoriesSet {
	[self willAccessValueForKey:@"repositories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"repositories"];
  
	[self didAccessValueForKey:@"repositories"];
	return result;
}
	






@end
