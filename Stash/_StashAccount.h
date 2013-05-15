// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StashAccount.h instead.

#import <CoreData/CoreData.h>


extern const struct StashAccountAttributes {
	__unsafe_unretained NSString *accountURLString;
	__unsafe_unretained NSString *avatarURLString;
	__unsafe_unretained NSString *dateStampOfLastSync;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *tokenIdentifier;
	__unsafe_unretained NSString *username;
} StashAccountAttributes;

extern const struct StashAccountRelationships {
	__unsafe_unretained NSString *repos;
} StashAccountRelationships;

extern const struct StashAccountFetchedProperties {
} StashAccountFetchedProperties;

@class StashRepo;









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





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* tokenIdentifier;



@property int64_t tokenIdentifierValue;
- (int64_t)tokenIdentifierValue;
- (void)setTokenIdentifierValue:(int64_t)value_;

//- (BOOL)validateTokenIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *repos;

- (NSMutableSet*)reposSet;





@end

@interface _StashAccount (CoreDataGeneratedAccessors)

- (void)addRepos:(NSSet*)value_;
- (void)removeRepos:(NSSet*)value_;
- (void)addReposObject:(StashRepo*)value_;
- (void)removeReposObject:(StashRepo*)value_;

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




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveTokenIdentifier;
- (void)setPrimitiveTokenIdentifier:(NSNumber*)value;

- (int64_t)primitiveTokenIdentifierValue;
- (void)setPrimitiveTokenIdentifierValue:(int64_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveRepos;
- (void)setPrimitiveRepos:(NSMutableSet*)value;


@end
