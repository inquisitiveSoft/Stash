// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashItem.h instead.

#import <CoreData/CoreData.h>


extern const struct StashItemAttributes {
	__unsafe_unretained NSString *hasLocalChanges;
} StashItemAttributes;

extern const struct StashItemRelationships {
	__unsafe_unretained NSString *changedVersion;
	__unsafe_unretained NSString *synchronizedVersion;
} StashItemRelationships;

extern const struct StashItemFetchedProperties {
} StashItemFetchedProperties;

@class StashItem;
@class StashItem;



@interface StashItemID : NSManagedObjectID {}
@end

@interface _StashItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashItemID*)objectID;





@property (nonatomic, strong) NSNumber* hasLocalChanges;



@property BOOL hasLocalChangesValue;
- (BOOL)hasLocalChangesValue;
- (void)setHasLocalChangesValue:(BOOL)value_;

//- (BOOL)validateHasLocalChanges:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) StashItem *changedVersion;

//- (BOOL)validateChangedVersion:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) StashItem *synchronizedVersion;

//- (BOOL)validateSynchronizedVersion:(id*)value_ error:(NSError**)error_;





@end

@interface _StashItem (CoreDataGeneratedAccessors)

@end

@interface _StashItem (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveHasLocalChanges;
- (void)setPrimitiveHasLocalChanges:(NSNumber*)value;

- (BOOL)primitiveHasLocalChangesValue;
- (void)setPrimitiveHasLocalChangesValue:(BOOL)value_;





- (StashItem*)primitiveChangedVersion;
- (void)setPrimitiveChangedVersion:(StashItem*)value;



- (StashItem*)primitiveSynchronizedVersion;
- (void)setPrimitiveSynchronizedVersion:(StashItem*)value;


@end
