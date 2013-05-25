// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashIssue.h instead.

#import <CoreData/CoreData.h>


extern const struct StashIssueAttributes {
	__unsafe_unretained NSString *assignee;
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *modificationDate;
	__unsafe_unretained NSString *number;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *syncedState;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *url;
} StashIssueAttributes;

extern const struct StashIssueRelationships {
	__unsafe_unretained NSString *labels;
	__unsafe_unretained NSString *milestones;
	__unsafe_unretained NSString *repo;
} StashIssueRelationships;

extern const struct StashIssueFetchedProperties {
} StashIssueFetchedProperties;

@class StashLabel;
@class StashMilestone;
@class StashRepo;













@interface StashIssueID : NSManagedObjectID {}
@end

@interface _StashIssue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashIssueID*)objectID;





@property (nonatomic, strong) NSString* assignee;



//- (BOOL)validateAssignee:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* body;



//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* color;



//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* identifier;



@property int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* modificationDate;



//- (BOOL)validateModificationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* number;



@property int64_t numberValue;
- (int64_t)numberValue;
- (void)setNumberValue:(int64_t)value_;

//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* state;



@property BOOL stateValue;
- (BOOL)stateValue;
- (void)setStateValue:(BOOL)value_;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* syncedState;



//- (BOOL)validateSyncedState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *labels;

- (NSMutableSet*)labelsSet;




@property (nonatomic, strong) NSSet *milestones;

- (NSMutableSet*)milestonesSet;




@property (nonatomic, strong) StashRepo *repo;

//- (BOOL)validateRepo:(id*)value_ error:(NSError**)error_;





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

@end

@interface _StashIssue (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAssignee;
- (void)setPrimitiveAssignee:(NSString*)value;




- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;




- (NSString*)primitiveColor;
- (void)setPrimitiveColor:(NSString*)value;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;




- (NSDate*)primitiveModificationDate;
- (void)setPrimitiveModificationDate:(NSDate*)value;




- (NSNumber*)primitiveNumber;
- (void)setPrimitiveNumber:(NSNumber*)value;

- (int64_t)primitiveNumberValue;
- (void)setPrimitiveNumberValue:(int64_t)value_;




- (NSNumber*)primitiveState;
- (void)setPrimitiveState:(NSNumber*)value;

- (BOOL)primitiveStateValue;
- (void)setPrimitiveStateValue:(BOOL)value_;




- (NSData*)primitiveSyncedState;
- (void)setPrimitiveSyncedState:(NSData*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (NSMutableSet*)primitiveLabels;
- (void)setPrimitiveLabels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMilestones;
- (void)setPrimitiveMilestones:(NSMutableSet*)value;



- (StashRepo*)primitiveRepo;
- (void)setPrimitiveRepo:(StashRepo*)value;


@end
