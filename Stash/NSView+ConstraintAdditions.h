//  Created by Harry Jordan on 24/04/2013.
//  Copyright (c) 2013 Inquisitive Software. All rights reserved.

#import <Cocoa/Cocoa.h>


extern NSString * const SYMLLayoutHorizontalFormat;
extern NSString * const SYMLLayoutVerticalFormat;
extern NSString * const SYMLLayoutHorizontalOptions;
extern NSString * const SYMLLayoutVerticalOptions;
extern NSString * const SYMLLayoutPriority;
extern NSString * const SYMLLayoutVerticalPriority;
extern NSString * const SYMLLayoutHorizontalPriority;
extern NSString * const SYMLLayoutMetrics;
extern NSString * const SYMLLayoutViews;


@interface NSView (SYMLConstraintAdditions)

- (void)addConstraintsWithParamaters:(NSDictionary *)constraints;
- (void)addConstraints:(NSArray *)constraints withPriority:(NSLayoutPriority)priority;

- (void)centerView:(NSView *)viewToCenter relativeToView:(NSView *)relativeToView xAxis:(BOOL)xAxis yAxis:(BOOL)yAxis;
- (void)fillView:(NSView *)parentView;

- (void)removeAllConstraints;

@end
