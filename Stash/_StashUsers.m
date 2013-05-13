// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashUsers.m instead.

#import "_StashUsers.h"

const struct StashUsersAttributes StashUsersAttributes = {
	.avatarURL = @"avatarURL",
	.identifier = @"identifier",
	.name = @"name",
};

const struct StashUsersRelationships StashUsersRelationships = {
	.repository = @"repository",
};

const struct StashUsersFetchedProperties StashUsersFetchedProperties = {
};

@implementation StashUsersID
@end

@implementation _StashUsers

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StashUsers" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StashUsers";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StashUsers" inManagedObjectContext:moc_];
}

- (StashUsersID*)objectID {
	return (StashUsersID*)[super objectID];
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





@dynamic name;






@dynamic repository;

	






@end
