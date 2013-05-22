// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashRepo.h instead.

#import <CoreData/CoreData.h>


extern const struct StashRepoAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *public;
} StashRepoAttributes;

extern const struct StashRepoRelationships {
	__unsafe_unretained NSString *account;
	__unsafe_unretained NSString *issues;
	__unsafe_unretained NSString *labels;
	__unsafe_unretained NSString *milestones;
	__unsafe_unretained NSString *users;
} StashRepoRelationships;

extern const struct StashRepoFetchedProperties {
} StashRepoFetchedProperties;

@class StashAccount;
@class StashIssue;
@class StashLabel;
@class StashMilestone;
@class StashUsers;





@interface StashRepoID : NSManagedObjectID {}
@end

@interface _StashRepo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashRepoID*)objectID;





@property (nonatomic, strong) NSNumber* identifier;



@property int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* public;



@property BOOL publicValue;
- (BOOL)publicValue;
- (void)setPublicValue:(BOOL)value_;

//- (BOOL)validatePublic:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) StashAccount *account;

//- (BOOL)validateAccount:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *issues;

- (NSMutableSet*)issuesSet;




@property (nonatomic, strong) NSSet *labels;

- (NSMutableSet*)labelsSet;




@property (nonatomic, strong) NSSet *milestones;

- (NSMutableSet*)milestonesSet;




@property (nonatomic, strong) NSSet *users;

- (NSMutableSet*)usersSet;





@end

@interface _StashRepo (CoreDataGeneratedAccessors)

- (void)addIssues:(NSSet*)value_;
- (void)removeIssues:(NSSet*)value_;
- (void)addIssuesObject:(StashIssue*)value_;
- (void)removeIssuesObject:(StashIssue*)value_;

- (void)addLabels:(NSSet*)value_;
- (void)removeLabels:(NSSet*)value_;
- (void)addLabelsObject:(StashLabel*)value_;
- (void)removeLabelsObject:(StashLabel*)value_;

- (void)addMilestones:(NSSet*)value_;
- (void)removeMilestones:(NSSet*)value_;
- (void)addMilestonesObject:(StashMilestone*)value_;
- (void)removeMilestonesObject:(StashMilestone*)value_;

- (void)addUsers:(NSSet*)value_;
- (void)removeUsers:(NSSet*)value_;
- (void)addUsersObject:(StashUsers*)value_;
- (void)removeUsersObject:(StashUsers*)value_;

@end

@interface _StashRepo (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePublic;
- (void)setPrimitivePublic:(NSNumber*)value;

- (BOOL)primitivePublicValue;
- (void)setPrimitivePublicValue:(BOOL)value_;





- (StashAccount*)primitiveAccount;
- (void)setPrimitiveAccount:(StashAccount*)value;



- (NSMutableSet*)primitiveIssues;
- (void)setPrimitiveIssues:(NSMutableSet*)value;



- (NSMutableSet*)primitiveLabels;
- (void)setPrimitiveLabels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMilestones;
- (void)setPrimitiveMilestones:(NSMutableSet*)value;



- (NSMutableSet*)primitiveUsers;
- (void)setPrimitiveUsers:(NSMutableSet*)value;


@end
