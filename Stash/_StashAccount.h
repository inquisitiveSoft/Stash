// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashAccount.h instead.

#import <CoreData/CoreData.h>


extern const struct StashAccountAttributes {
	__unsafe_unretained NSString *accountURLString;
	__unsafe_unretained NSString *avatarURLString;
	__unsafe_unretained NSString *dateStampOfLastSync;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *username;
} StashAccountAttributes;

extern const struct StashAccountRelationships {
	__unsafe_unretained NSString *repositories;
} StashAccountRelationships;

extern const struct StashAccountFetchedProperties {
} StashAccountFetchedProperties;

@class StashRepository;







@interface StashAccountID : NSManagedObjectID {}
@end

@interface _StashAccount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StashAccountID*)objectID;





@property (nonatomic, strong) NSString* accountURLString;



//- (BOOL)validateAccountURLString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* avatarURLString;



//- (BOOL)validateAvatarURLString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateStampOfLastSync;



//- (BOOL)validateDateStampOfLastSync:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* identifier;



@property int64_t identifierValue;
- (int64_t)identifierValue;
- (void)setIdentifierValue:(int64_t)value_;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *repositories;

- (NSMutableSet*)repositoriesSet;





@end

@interface _StashAccount (CoreDataGeneratedAccessors)

- (void)addRepositories:(NSSet*)value_;
- (void)removeRepositories:(NSSet*)value_;
- (void)addRepositoriesObject:(StashRepository*)value_;
- (void)removeRepositoriesObject:(StashRepository*)value_;

@end

@interface _StashAccount (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAccountURLString;
- (void)setPrimitiveAccountURLString:(NSString*)value;




- (NSString*)primitiveAvatarURLString;
- (void)setPrimitiveAvatarURLString:(NSString*)value;




- (NSDate*)primitiveDateStampOfLastSync;
- (void)setPrimitiveDateStampOfLastSync:(NSDate*)value;




- (NSNumber*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSNumber*)value;

- (int64_t)primitiveIdentifierValue;
- (void)setPrimitiveIdentifierValue:(int64_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveRepositories;
- (void)setPrimitiveRepositories:(NSMutableSet*)value;


@end
