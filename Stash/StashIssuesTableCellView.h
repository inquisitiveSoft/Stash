#import <Cocoa/Cocoa.h>

@class StashIssue;


@interface StashIssuesTableCellView : NSTableCellView

@property (strong, nonatomic) IBOutlet NSTextField *numberLabel;
@property (strong, nonatomic) IBOutlet NSButton *checkboxButton;

@property (strong, nonatomic) StashIssue *issue;

@end
