// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashUsers.h instead.

#import <CoreData/CoreData.h>


extern const struct StashUsersAttributes {
	__unsafe_unretained NSString *avatarURL;
	__unsafe_unretained NSString *name;
} StashUsersAttributes;

extern const struct StashUsersRelationships {
	__unsafe_unretained NSString *repo;
} StashUsersRelationships;

extern const struct StashUsersFetchedProperties {
} StashUsersFetchedProperties;

@class StashRepo;




@interface StashUsersID : NSManagedObjectID {}
@end

@interface _StashUsers : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashUsersID*)objectID;





@property (nonatomic, strong) NSString* avatarURL;



//- (BOOL)validateAvatarURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) StashRepo *repo;

//- (BOOL)validateRepo:(id*)value_ error:(NSError**)error_;





@end

@interface _StashUsers (CoreDataGeneratedAccessors)

@end

@interface _StashUsers (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAvatarURL;
- (void)setPrimitiveAvatarURL:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (StashRepo*)primitiveRepo;
- (void)setPrimitiveRepo:(StashRepo*)value;


@end
