#import "StashViewController.h"
#import "StashNetworkManager.h"


typedef NS_ENUM(NSUInteger, StashIssuesViewMode) {
	StashIssuesViewModeUnknown,
	StashIssuesViewModeFiltering,
	StashIssuesViewModeCreation
};



@interface StashIssuesViewController : StashViewController <NSTextViewDelegate, NSTableViewDelegate, NSTableViewDataSource>



@end
