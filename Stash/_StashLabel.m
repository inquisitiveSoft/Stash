// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashLabel.m instead.

#import "_StashLabel.h"

const struct StashLabelAttributes StashLabelAttributes = {
	.color = @"color",
	.identifier = @"identifier",
	.name = @"name",
};

const struct StashLabelRelationships StashLabelRelationships = {
	.issues = @"issues",
	.repository = @"repository",
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
	
	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic color;






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






@dynamic issues;

	
- (NSMutableSet*)issuesSet {
	[self willAccessValueForKey:@"issues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"issues"];
  
	[self didAccessValueForKey:@"issues"];
	return result;
}
	

@dynamic repository;

	
- (NSMutableSet*)repositorySet {
	[self willAccessValueForKey:@"repository"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"repository"];
  
	[self didAccessValueForKey:@"repository"];
	return result;
}
	






@end
