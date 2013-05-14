// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashIssue.h instead.

#import <CoreData/CoreData.h>
#import "StashItem.h"

extern const struct StashIssueAttributes {
	__unsafe_unretained NSString *assignee;
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *issueNumber;
	__unsafe_unretained NSString *modificationDate;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *url;
} StashIssueAttributes;

extern const struct StashIssueRelationships {
	__unsafe_unretained NSString *labels;
	__unsafe_unretained NSString *milestones;
	__unsafe_unretained NSString *repository;
} StashIssueRelationships;

extern const struct StashIssueFetchedProperties {
} StashIssueFetchedProperties;

@class StashLabel;
@class StashMilestone;
@class StashRepository;











@interface StashIssueID : NSManagedObjectID {}
@end

@interface _StashIssue : StashItem {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashIssueID*)objectID;





@property (nonatomic, strong) NSString* assignee;



//- (BOOL)validateAssignee:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* body;



//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* issueNumber;



@property int64_t issueNumberValue;
- (int64_t)issueNumberValue;
- (void)setIssueNumberValue:(int64_t)value_;

//- (BOOL)validateIssueNumber:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* modificationDate;



//- (BOOL)validateModificationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* state;



@property int16_t stateValue;
- (int16_t)stateValue;
- (void)setStateValue:(int16_t)value_;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *labels;

- (NSMutableSet*)labelsSet;




@property (nonatomic, strong) NSSet *milestones;

- (NSMutableSet*)milestonesSet;




@property (nonatomic, strong) NSSet *repository;

- (NSMutableSet*)repositorySet;





@end

@interface _StashIssue (CoreDataGeneratedAccessors)

- (void)addLabels:(NSSet*)value_;
- (void)removeLabels:(NSSet*)value_;
- (void)addLabelsObject:(StashLabel*)value_;
- (void)removeLabelsObject:(StashLabel*)value_;

- (void)addMilestones:(NSSet*)value_;
- (void)removeMilestones:(NSSet*)value_;
- (void)addMilestonesObject:(StashMilestone*)value_;
- (void)removeMilestonesObject:(StashMilestone*)value_;

- (void)addRepository:(NSSet*)value_;
- (void)removeRepository:(NSSet*)value_;
- (void)addRepositoryObject:(StashRepository*)value_;
- (void)removeRepositoryObject:(StashRepository*)value_;

@end

@interface _StashIssue (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAssignee;
- (void)setPrimitiveAssignee:(NSString*)value;




- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSNumber*)primitiveIssueNumber;
- (void)setPrimitiveIssueNumber:(NSNumber*)value;

- (int64_t)primitiveIssueNumberValue;
- (void)setPrimitiveIssueNumberValue:(int64_t)value_;




- (NSDate*)primitiveModificationDate;
- (void)setPrimitiveModificationDate:(NSDate*)value;




- (NSNumber*)primitiveState;
- (void)setPrimitiveState:(NSNumber*)value;

- (int16_t)primitiveStateValue;
- (void)setPrimitiveStateValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (NSMutableSet*)primitiveLabels;
- (void)setPrimitiveLabels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMilestones;
- (void)setPrimitiveMilestones:(NSMutableSet*)value;



- (NSMutableSet*)primitiveRepository;
- (void)setPrimitiveRepository:(NSMutableSet*)value;


@end
