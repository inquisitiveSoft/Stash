// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashLabel.m instead.

#import "_StashLabel.h"

const struct StashLabelAttributes StashLabelAttributes = {
	.color = @"color",
	.name = @"name",
};

const struct StashLabelRelationships StashLabelRelationships = {
	.issues = @"issues",
	.repo = @"repo",
};

const struct StashLabelFetchedProperties StashLabelFetchedProperties = {
};

@implementation StashLabelID
@end

@implementation _StashLabel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StashLabel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StashLabel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StashLabel" inManagedObjectContext:moc_];
}

- (StashLabelID*)objectID {
	return (StashLabelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic color;






@dynamic name;






@dynamic issues;

	
- (NSMutableSet*)issuesSet {
	[self willAccessValueForKey:@"issues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"issues"];
  
	[self didAccessValueForKey:@"issues"];
	return result;
}
	

@dynamic repo;

	






@end
