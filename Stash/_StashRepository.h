// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashRepository.h instead.

#import <CoreData/CoreData.h>


extern const struct StashRepositoryAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *name;
} StashRepositoryAttributes;

extern const struct StashRepositoryRelationships {
	__unsafe_unretained NSString *account;
	__unsafe_unretained NSString *issues;
	__unsafe_unretained NSString *labels;
	__unsafe_unretained NSString *milestones;
	__unsafe_unretained NSString *users;
} StashRepositoryRelationships;

extern const struct StashRepositoryFetchedProperties {
} StashRepositoryFetchedProperties;

@class StashAccount;
@class StashIssue;
@class StashLabel;
@class StashMilestone;
@class StashUsers;




@interface StashRepositoryID : NSManagedObjectID {}
@end

@interface _StashRepository : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashRepositoryID*)objectID;





@property (nonatomic, strong) NSNumber* identifier;



@property int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





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

@interface _StashRepository (CoreDataGeneratedAccessors)

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

@interface _StashRepository (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





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
