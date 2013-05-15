#import <Foundation/Foundation.h>



@interface NSURLRequest (StashTokenIdentifier)

// Stores a token identifier as a reference to use
// when returning from a block.
@property (assign, nonatomic) NSNumber *tokenIdentifier;

// Store an attached object
@property (strong, nonatomic) id attachedObject;

@end
