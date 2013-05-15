// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashIssue.m instead.

#import "_StashIssue.h"

const struct StashIssueAttributes StashIssueAttributes = {
	.assignee = @"assignee",
	.body = @"body",
	.creationDate = @"creationDate",
	.identifier = @"identifier",
	.modificationDate = @"modificationDate",
	.number = @"number",
	.state = @"state",
	.syncedState = @"syncedState",
	.title = @"title",
	.url = @"url",
};

const struct StashIssueRelationships StashIssueRelationships = {
	.labels = @"labels",
	.milestones = @"milestones",
	.repo = @"repo",
};

const struct StashIssueFetchedProperties StashIssueFetchedProperties = {
};

@implementation StashIssueID
@end

@implementation _StashIssue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StashIssue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StashIssue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StashIssue" inManagedObjectContext:moc_];
}

- (StashIssueID*)objectID {
	return (StashIssueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"identifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"identifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"numberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"number"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"stateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"state"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic assignee;






@dynamic body;






@dynamic creationDate;






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






@dynamic number;



- (int64_t)numberValue {
	NSNumber *result = [self number];
	return [result longLongValue];
}

- (void)setNumberValue:(int64_t)value_ {
	[self setNumber:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveNumberValue {
	NSNumber *result = [self primitiveNumber];
	return [result longLongValue];
}

- (void)setPrimitiveNumberValue:(int64_t)value_ {
	[self setPrimitiveNumber:[NSNumber numberWithLongLong:value_]];
}





@dynamic state;



- (int16_t)stateValue {
	NSNumber *result = [self state];
	return [result shortValue];
}

- (void)setStateValue:(int16_t)value_ {
	[self setState:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStateValue {
	NSNumber *result = [self primitiveState];
	return [result shortValue];
}

- (void)setPrimitiveStateValue:(int16_t)value_ {
	[self setPrimitiveState:[NSNumber numberWithShort:value_]];
}





@dynamic syncedState;






@dynamic title;






@dynamic url;






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
	

@dynamic repo;

	






@end
