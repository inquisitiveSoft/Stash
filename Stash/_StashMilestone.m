// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashMilestone.m instead.

#import "_StashMilestone.h"

const struct StashMilestoneAttributes StashMilestoneAttributes = {
	.body = @"body",
	.creationDate = @"creationDate",
	.dueDate = @"dueDate",
	.identifier = @"identifier",
	.modificationDate = @"modificationDate",
	.title = @"title",
};

const struct StashMilestoneRelationships StashMilestoneRelationships = {
	.issues = @"issues",
	.repository = @"repository",
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
	
	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic body;






@dynamic creationDate;






@dynamic dueDate;






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





@dynamic modificationDate;






@dynamic title;






@dynamic issues;

	
- (NSMutableSet*)issuesSet {
	[self willAccessValueForKey:@"issues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"issues"];
  
	[self didAccessValueForKey:@"issues"];
	return result;
}
	

@dynamic repository;

	






@end
