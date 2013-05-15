// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashUsers.m instead.

#import "_StashUsers.h"

const struct StashUsersAttributes StashUsersAttributes = {
	.avatarURL = @"avatarURL",
	.name = @"name",
};

const struct StashUsersRelationships StashUsersRelationships = {
	.repo = @"repo",
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
	

	return keyPaths;
}




@dynamic avatarURL;






@dynamic name;






@dynamic repo;

	






@end
