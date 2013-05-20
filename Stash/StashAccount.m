#import "StashAccount.h"
#import "StashRepo.h"


@interface StashAccount ()

// Private interface goes here.

@end


@implementation StashAccount


- (void)updateAccountDetailsWithDictionary:(NSDictionary *)accountDetails
{
	self.identifier = accountDetails[@"id"];
	self.name = accountDetails[@"name"];
	self.username = accountDetails[@"login"];
	self.avatarURLString = accountDetails[@"avatar_url"];
	self.accountURLString = accountDetails[@"html_url"];
}


- (void)setCurrentRepo:(StashRepo *)currentRepo
{
	self.currentRepoIdentifier = currentRepo.identifier;
}


- (StashRepo *)currentRepo
{
	StashRepo *currentRepo = nil;
	NSNumber *currentRepoIdentifier = self.currentRepoIdentifier;
	
	for(StashRepo *repo in [self repos]) {
		if(!currentRepoIdentifier || [repo.identifier isEqualToNumber:currentRepoIdentifier]) {
			currentRepo = repo;
			break;
		}
	}
	
	return currentRepo;
}


@end
