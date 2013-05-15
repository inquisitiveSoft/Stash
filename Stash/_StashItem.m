// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashItem.m instead.

#import "_StashItem.h"

const struct StashItemAttributes StashItemAttributes = {
};

const struct StashItemRelationships StashItemRelationships = {
	.changedVersion = @"changedVersion",
	.syncedVersion = @"syncedVersion",
};

const struct StashItemFetchedProperties StashItemFetchedProperties = {
};

@implementation StashItemID
@end

@implementation _StashItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StashItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StashItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StashItem" inManagedObjectContext:moc_];
}

- (StashItemID*)objectID {
	return (StashItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic changedVersion;

	

@dynamic syncedVersion;

	






@end
