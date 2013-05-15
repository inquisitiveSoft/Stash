// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashItem.h instead.

#import <CoreData/CoreData.h>


extern const struct StashItemAttributes {
} StashItemAttributes;

extern const struct StashItemRelationships {
	__unsafe_unretained NSString *changedVersion;
	__unsafe_unretained NSString *syncedVersion;
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





@property (nonatomic, strong) StashItem *changedVersion;

//- (BOOL)validateChangedVersion:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) StashItem *syncedVersion;

//- (BOOL)validateSyncedVersion:(id*)value_ error:(NSError**)error_;





@end

@interface _StashItem (CoreDataGeneratedAccessors)

@end

@interface _StashItem (CoreDataGeneratedPrimitiveAccessors)



- (StashItem*)primitiveChangedVersion;
- (void)setPrimitiveChangedVersion:(StashItem*)value;



- (StashItem*)primitiveSyncedVersion;
- (void)setPrimitiveSyncedVersion:(StashItem*)value;


@end
