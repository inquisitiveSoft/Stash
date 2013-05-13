// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashUsers.h instead.

#import <CoreData/CoreData.h>


extern const struct StashUsersAttributes {
	__unsafe_unretained NSString *avatarURL;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *name;
} StashUsersAttributes;

extern const struct StashUsersRelationships {
	__unsafe_unretained NSString *repository;
} StashUsersRelationships;

extern const struct StashUsersFetchedProperties {
} StashUsersFetchedProperties;

@class StashRepository;





@interface StashUsersID : NSManagedObjectID {}
@end

@interface _StashUsers : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashUsersID*)objectID;





@property (nonatomic, strong) NSString* avatarURL;



//- (BOOL)validateAvatarURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* identifier;



@property int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) StashRepository *repository;

//- (BOOL)validateRepository:(id*)value_ error:(NSError**)error_;





@end

@interface _StashUsers (CoreDataGeneratedAccessors)

@end

@interface _StashUsers (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAvatarURL;
- (void)setPrimitiveAvatarURL:(NSString*)value;




- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (StashRepository*)primitiveRepository;
- (void)setPrimitiveRepository:(StashRepository*)value;


@end
