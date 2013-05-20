// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashAccount.m instead.

#import "_StashAccount.h"

const struct StashAccountAttributes StashAccountAttributes = {
	.accountURLString = @"accountURLString",
	.avatarURLString = @"avatarURLString",
	.currentRepoIdentifier = @"currentRepoIdentifier",
	.dateStampOfLastSync = @"dateStampOfLastSync",
	.identifier = @"identifier",
	.name = @"name",
	.tokenIdentifier = @"tokenIdentifier",
	.username = @"username",
};

const struct StashAccountRelationships StashAccountRelationships = {
	.repos = @"repos",
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
	
	if ([key isEqualToString:@"currentRepoIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"currentRepoIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"tokenIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tokenIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic accountURLString;






@dynamic avatarURLString;






@dynamic currentRepoIdentifier;



- (int64_t)currentRepoIdentifierValue {
	NSNumber *result = [self currentRepoIdentifier];
	return [result longLongValue];
}

- (void)setCurrentRepoIdentifierValue:(int64_t)value_ {
	[self setCurrentRepoIdentifier:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveCurrentRepoIdentifierValue {
	NSNumber *result = [self primitiveCurrentRepoIdentifier];
	return [result longLongValue];
}

- (void)setPrimitiveCurrentRepoIdentifierValue:(int64_t)value_ {
	[self setPrimitiveCurrentRepoIdentifier:[NSNumber numberWithLongLong:value_]];
}





@dynamic dateStampOfLastSync;






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





@dynamic name;






@dynamic tokenIdentifier;



- (int64_t)tokenIdentifierValue {
	NSNumber *result = [self tokenIdentifier];
	return [result longLongValue];
}

- (void)setTokenIdentifierValue:(int64_t)value_ {
	[self setTokenIdentifier:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTokenIdentifierValue {
	NSNumber *result = [self primitiveTokenIdentifier];
	return [result longLongValue];
}

- (void)setPrimitiveTokenIdentifierValue:(int64_t)value_ {
	[self setPrimitiveTokenIdentifier:[NSNumber numberWithLongLong:value_]];
}





@dynamic username;






@dynamic repos;

	
- (NSMutableSet*)reposSet {
	[self willAccessValueForKey:@"repos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"repos"];
  
	[self didAccessValueForKey:@"repos"];
	return result;
}
	






@end
