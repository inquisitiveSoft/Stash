#import <Cocoa/Cocoa.h>


@interface StashIssueCollectionViewItem : NSCollectionViewItem

@property (strong, nonatomic) IBOutlet NSTextField *numberField;
@property (strong, nonatomic) IBOutlet NSButton *statusCheckboxButton;

@end
