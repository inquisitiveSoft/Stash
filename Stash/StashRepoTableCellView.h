#import <Cocoa/Cocoa.h>


@interface StashRepoTableCellView : NSTableCellView

@property (readonly, nonatomic) NSTextField *numberLabel;

- (NSFont *)labelFont;

@end
