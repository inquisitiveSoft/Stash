#import <Cocoa/Cocoa.h>
#import "StashView.h"


typedef NS_ENUM(NSUInteger, StashButtonState) {
	StashButtonStateMixed = -1,
	StashButtonStateNormal = 0,
	StashButtonStateSelected = 1
};


typedef NS_ENUM(NSUInteger, StashButtonTitlePosition) {
	StashButtonTitlePositionCenter,
	StashButtonTitlePositionLeft,
	StashButtonTitlePositionRight
};


@class StashButton;
typedef void (^ StashButtonLayoutBlock)(StashButton *button, NSRectPointer titleRect, NSRectPointer imageRect);


@interface StashButton : NSButton

@property (copy, nonatomic) NSColor *backgroundColor;
@property (copy, nonatomic) NSImage *backgroundImage;
@property (copy, nonatomic) StashViewDrawBlock drawBlock;

@property (assign, nonatomic) NSEdgeInsets contentInsets;
@property (assign, nonatomic) StashButtonTitlePosition titlePosition;
@property (assign, nonatomic) StashButtonState buttonState;
@property (assign, nonatomic) NSSize shadowOffset;
@property (assign, nonatomic) CGFloat shadowRadius;

@property (strong, nonatomic) StashButtonLayoutBlock layoutBlock;


// Colors
- (void)setTitleColor:(NSColor *)color forState:(StashButtonState)state;
- (NSColor *)titleColorForState:(StashButtonState)state;

- (void)setTitleShadowColor:(NSColor *)color forState:(StashButtonState)state;
- (NSColor *)titleShadowColorForState:(StashButtonState)state;


@end
