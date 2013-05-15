// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashRepo.m instead.

#import "_StashRepo.h"

const struct StashRepoAttributes StashRepoAttributes = {
	.identifier = @"identifier",
	.name = @"name",
};

const struct StashRepoRelationships StashRepoRelationships = {
	.account = @"account",
	.issues = @"issues",
	.labels = @"labels",
	.milestones = @"milestones",
	.users = @"users",
};

const struct StashRepoFetchedProperties StashRepoFetchedProperties = {
};

@implementation StashRepoID
@end

@implementation _StashRepo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StashRepo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StashRepo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StashRepo" inManagedObjectContext:moc_];
}

- (StashRepoID*)objectID {
	return (StashRepoID*)[super objectID];
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






@dynamic account;

	

@dynamic issues;

	
- (NSMutableSet*)issuesSet {
	[self willAccessValueForKey:@"issues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"issues"];
  
	[self didAccessValueForKey:@"issues"];
	return result;
}
	

@dynamic labels;

	
- (NSMutableSet*)labelsSet {
	[self willAccessValueForKey:@"labels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"labels"];
  
	[self didAccessValueForKey:@"labels"];
	return result;
}
	

@dynamic milestones;

	
- (NSMutableSet*)milestonesSet {
	[self willAccessValueForKey:@"milestones"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"milestones"];
  
	[self didAccessValueForKey:@"milestones"];
	return result;
}
	

@dynamic users;

	
- (NSMutableSet*)usersSet {
	[self willAccessValueForKey:@"users"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"users"];
  
	[self didAccessValueForKey:@"users"];
	return result;
}
	






@end
