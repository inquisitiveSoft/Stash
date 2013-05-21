#import "StashViewController.h"
#import "StashNetworkManager.h"


typedef enum StashIssuesViewMode : NSUInteger {
	StashIssuesViewModeUnknown,
	StashIssuesViewModeFiltering,
	StashIssuesViewModeCreation
} StashIssuesViewMode;


@interface StashIssuesViewController : StashViewController <NSTextViewDelegate, NSCollectionViewDelegate>



@end
