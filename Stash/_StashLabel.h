// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashLabel.h instead.

#import <CoreData/CoreData.h>
#import "StashItem.h"

extern const struct StashLabelAttributes {
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *name;
} StashLabelAttributes;

extern const struct StashLabelRelationships {
	__unsafe_unretained NSString *issues;
	__unsafe_unretained NSString *repository;
} StashLabelRelationships;

extern const struct StashLabelFetchedProperties {
} StashLabelFetchedProperties;

@class StashIssue;
@class StashRepository;





@interface StashLabelID : NSManagedObjectID {}
@end

@interface _StashLabel : StashItem {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashLabelID*)objectID;





@property (nonatomic, strong) NSString* color;



//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* identifier;



@property int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *issues;

- (NSMutableSet*)issuesSet;




@property (nonatomic, strong) NSSet *repository;

- (NSMutableSet*)repositorySet;





@end

@interface _StashLabel (CoreDataGeneratedAccessors)

- (void)addIssues:(NSSet*)value_;
- (void)removeIssues:(NSSet*)value_;
- (void)addIssuesObject:(StashIssue*)value_;
- (void)removeIssuesObject:(StashIssue*)value_;

- (void)addRepository:(NSSet*)value_;
- (void)removeRepository:(NSSet*)value_;
- (void)addRepositoryObject:(StashRepository*)value_;
- (void)removeRepositoryObject:(StashRepository*)value_;

@end

@interface _StashLabel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveColor;
- (void)setPrimitiveColor:(NSString*)value;




- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveIssues;
- (void)setPrimitiveIssues:(NSMutableSet*)value;



- (NSMutableSet*)primitiveRepository;
- (void)setPrimitiveRepository:(NSMutableSet*)value;


@end
