#import "NSURLRequest+TokenIdentifier.h"
#import <objc/objc-runtime.h>


NSString * const StashNSURLRequestTokenIdentifierKey = @"StashNSURLRequestTokenIdentifierKey";
NSString * const StashNSURLRequestAttachedObjectKey = @"StashNSURLRequestAttachedObjectKey";


@implementation NSURLRequest (StashTokenIdentifier)


- (void)setTokenIdentifier:(NSNumber *)tokenIdentifier
{
	objc_setAssociatedObject(self, (__bridge const void *)StashNSURLRequestTokenIdentifierKey, tokenIdentifier, OBJC_ASSOCIATION_COPY);
}


- (NSNumber *)tokenIdentifier
{
	return objc_getAssociatedObject(self, (__bridge const void *)StashNSURLRequestTokenIdentifierKey);
}


- (void)setAttachedObject:(id)attachedObject
{
	objc_setAssociatedObject(self, (__bridge const void *)StashNSURLRequestAttachedObjectKey, attachedObject, OBJC_ASSOCIATION_COPY);
}


- (id)attachedObject
{
	return objc_getAssociatedObject(self, (__bridge const void *)StashNSURLRequestAttachedObjectKey);
}


@end
