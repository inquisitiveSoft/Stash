// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashMilestone.h instead.

#import <CoreData/CoreData.h>
#import "StashItem.h"

extern const struct StashMilestoneAttributes {
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *creationDate;
	__unsafe_unretained NSString *dueDate;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *modificationDate;
	__unsafe_unretained NSString *title;
} StashMilestoneAttributes;

extern const struct StashMilestoneRelationships {
	__unsafe_unretained NSString *issues;
	__unsafe_unretained NSString *repository;
} StashMilestoneRelationships;

extern const struct StashMilestoneFetchedProperties {
} StashMilestoneFetchedProperties;

@class StashIssue;
@class StashRepository;








@interface StashMilestoneID : NSManagedObjectID {}
@end

@interface _StashMilestone : StashItem {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashMilestoneID*)objectID;





@property (nonatomic, strong) NSString* body;



//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* creationDate;



//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dueDate;



//- (BOOL)validateDueDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* identifier;



@property int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* modificationDate;



//- (BOOL)validateModificationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *issues;

- (NSMutableSet*)issuesSet;




@property (nonatomic, strong) StashRepository *repository;

//- (BOOL)validateRepository:(id*)value_ error:(NSError**)error_;





@end

@interface _StashMilestone (CoreDataGeneratedAccessors)

- (void)addIssues:(NSSet*)value_;
- (void)removeIssues:(NSSet*)value_;
- (void)addIssuesObject:(StashIssue*)value_;
- (void)removeIssuesObject:(StashIssue*)value_;

@end

@interface _StashMilestone (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;




- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;




- (NSDate*)primitiveDueDate;
- (void)setPrimitiveDueDate:(NSDate*)value;




- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;




- (NSDate*)primitiveModificationDate;
- (void)setPrimitiveModificationDate:(NSDate*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (NSMutableSet*)primitiveIssues;
- (void)setPrimitiveIssues:(NSMutableSet*)value;



- (StashRepository*)primitiveRepository;
- (void)setPrimitiveRepository:(StashRepository*)value;


@end
