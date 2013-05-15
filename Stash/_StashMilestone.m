// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashMilestone.m instead.

#import "_StashMilestone.h"

const struct StashMilestoneAttributes StashMilestoneAttributes = {
	.body = @"body",
	.creationDate = @"creationDate",
	.dueDate = @"dueDate",
	.modificationDate = @"modificationDate",
	.title = @"title",
};

const struct StashMilestoneRelationships StashMilestoneRelationships = {
	.issues = @"issues",
	.repo = @"repo",
};

const struct StashMilestoneFetchedProperties StashMilestoneFetchedProperties = {
};

@implementation StashMilestoneID
@end

@implementation _StashMilestone

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StashMilestone" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StashMilestone";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StashMilestone" inManagedObjectContext:moc_];
}

- (StashMilestoneID*)objectID {
	return (StashMilestoneID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic body;






@dynamic creationDate;






@dynamic dueDate;






@dynamic modificationDate;






@dynamic title;






@dynamic issues;

	
- (NSMutableSet*)issuesSet {
	[self willAccessValueForKey:@"issues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"issues"];
  
	[self didAccessValueForKey:@"issues"];
	return result;
}
	

@dynamic repo;

	






@end
