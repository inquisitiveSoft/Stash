// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashItem.m instead.

#import "_StashItem.h"

const struct StashItemAttributes StashItemAttributes = {
	.hasLocalChanges = @"hasLocalChanges",
};

const struct StashItemRelationships StashItemRelationships = {
	.changedVersion = @"changedVersion",
	.synchronizedVersion = @"synchronizedVersion",
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
	
	if ([key isEqualToString:@"hasLocalChangesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasLocalChanges"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic hasLocalChanges;



- (BOOL)hasLocalChangesValue {
	NSNumber *result = [self hasLocalChanges];
	return [result boolValue];
}

- (void)setHasLocalChangesValue:(BOOL)value_ {
	[self setHasLocalChanges:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasLocalChangesValue {
	NSNumber *result = [self primitiveHasLocalChanges];
	return [result boolValue];
}

- (void)setPrimitiveHasLocalChangesValue:(BOOL)value_ {
	[self setPrimitiveHasLocalChanges:[NSNumber numberWithBool:value_]];
}





@dynamic changedVersion;

	

@dynamic synchronizedVersion;

	






@end
