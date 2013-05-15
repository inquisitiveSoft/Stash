// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashLabel.h instead.

#import <CoreData/CoreData.h>


extern const struct StashLabelAttributes {
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *name;
} StashLabelAttributes;

extern const struct StashLabelRelationships {
	__unsafe_unretained NSString *issues;
	__unsafe_unretained NSString *repo;
} StashLabelRelationships;

extern const struct StashLabelFetchedProperties {
} StashLabelFetchedProperties;

@class StashIssue;
@class StashRepo;




@interface StashLabelID : NSManagedObjectID {}
@end

@interface _StashLabel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashLabelID*)objectID;





@property (nonatomic, strong) NSString* color;



//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *issues;

- (NSMutableSet*)issuesSet;




@property (nonatomic, strong) StashRepo *repo;

//- (BOOL)validateRepo:(id*)value_ error:(NSError**)error_;





@end

@interface _StashLabel (CoreDataGeneratedAccessors)

- (void)addIssues:(NSSet*)value_;
- (void)removeIssues:(NSSet*)value_;
- (void)addIssuesObject:(StashIssue*)value_;
- (void)removeIssuesObject:(StashIssue*)value_;

@end

@interface _StashLabel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveColor;
- (void)setPrimitiveColor:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveIssues;
- (void)setPrimitiveIssues:(NSMutableSet*)value;



- (StashRepo*)primitiveRepo;
- (void)setPrimitiveRepo:(StashRepo*)value;


@end
