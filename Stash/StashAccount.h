#import "_StashAccount.h"


@interface StashAccount : _StashAccount {}

- (void)updateAccountDetailsWithDictionary:(NSDictionary *)accountDetails;

@property (assign) StashRepo *currentRepo;


@end
