// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashIssue.m instead.

#import "_StashIssue.h"

const struct StashIssueAttributes StashIssueAttributes = {
	.assignee = @"assignee",
	.body = @"body",
	.creationDate = @"creationDate",
	.identifier = @"identifier",
	.issueNumber = @"issueNumber",
	.modificationDate = @"modificationDate",
	.state = @"state",
	.title = @"title",
	.url = @"url",
};

const struct StashIssueRelationships StashIssueRelationships = {
	.labels = @"labels",
	.milestones = @"milestones",
	.repository = @"repository",
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
	
	if ([key isEqualToString:@"issueNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"issueNumber"];
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






@dynamic issueNumber;



- (int64_t)issueNumberValue {
	NSNumber *result = [self issueNumber];
	return [result longLongValue];
}

- (void)setIssueNumberValue:(int64_t)value_ {
	[self setIssueNumber:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveIssueNumberValue {
	NSNumber *result = [self primitiveIssueNumber];
	return [result longLongValue];
}

- (void)setPrimitiveIssueNumberValue:(int64_t)value_ {
	[self setPrimitiveIssueNumber:[NSNumber numberWithLongLong:value_]];
}





@dynamic modificationDate;






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
	

@dynamic repository;

	
- (NSMutableSet*)repositorySet {
	[self willAccessValueForKey:@"repository"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"repository"];
  
	[self didAccessValueForKey:@"repository"];
	return result;
}
	






@end
