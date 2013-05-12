//  Created by Harry Jordan on 24/04/2013.
//  Copyright (c) 2013 Inquisitive Software. All rights reserved.


#import "NSView+ConstraintAdditions.h"


NSString * const SYMLLayoutHorizontalFormat = @"SYMLLayoutHorizontalFormat";
NSString * const SYMLLayoutVerticalFormat = @"SYMLLayoutVerticalFormat";

NSString * const SYMLLayoutHorizontalOptions = @"SYMLLayoutHorizontalOptions";
NSString * const SYMLLayoutVerticalOptions = @"SYMLLayoutVerticalOptions";

NSString * const SYMLLayoutPriority = @"SYMLLayoutPriority";						// A number between 0 and 1000
NSString * const SYMLLayoutHorizontalPriority = @"SYMLLayoutHorizontalPriority";	// Specific horizontal and vertical priorities will override the more general SYMLLayoutPriority
NSString * const SYMLLayoutVerticalPriority = @"SYMLLayoutVerticalPriority";

NSString * const SYMLLayoutMetrics = @"SYMLLayoutMetrics";						// A dictionary of metrics: @"metricName" : @(float)
NSString * const SYMLLayoutViews = @"SYMLLayoutViews";



@implementation NSView (SYMLConstraintAdditions)


- (void)addConstraintsWithParamaters:(NSDictionary *)parameters
{
	NSDictionary *views = [parameters objectForKey:SYMLLayoutViews];
	NSString *horizontalFormat = [parameters objectForKey:SYMLLayoutHorizontalFormat];
	NSString *verticalFormat = [parameters objectForKey:SYMLLayoutVerticalFormat];
	
	if(views && (horizontalFormat || verticalFormat)) {
		NSDictionary *metrics = [parameters objectForKey:SYMLLayoutMetrics];
				
		if([horizontalFormat length]) {
			NSLayoutFormatOptions horizontalOptions = 0;
			NSNumber *layoutOptions = [parameters objectForKey:SYMLLayoutHorizontalOptions];
			if([layoutOptions respondsToSelector:@selector(integerValue)])
				horizontalOptions = [layoutOptions integerValue];
		
			NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:horizontalFormat options:horizontalOptions metrics:metrics views:views];
			
			// Apply a priority to each constraint
			NSNumber *priorityValue = [parameters valueForKey:SYMLLayoutHorizontalPriority] ? : [parameters valueForKey:SYMLLayoutPriority];
			
			if(priorityValue && [priorityValue respondsToSelector:@selector(integerValue)]) {
				for(NSLayoutConstraint *constraint in constraints)
					constraint.priority = [priorityValue integerValue];
			}
			
			[self addConstraints:constraints];
		}
		
		if([verticalFormat length]) {
			NSLayoutFormatOptions verticalOptions = 0;
			NSNumber *layoutOptions = [parameters objectForKey:SYMLLayoutVerticalOptions];
			if([layoutOptions respondsToSelector:@selector(integerValue)])
				verticalOptions = [layoutOptions integerValue];
			
			// Add the V: if none exists already
			if([verticalFormat length] <= 2 || ![[verticalFormat substringToIndex:2] isEqualToString:@"V:"])
				verticalFormat = [@"V:" stringByAppendingString:verticalFormat];
			
			NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalFormat options:verticalOptions metrics:metrics views:views];
			
			// Apply a priority to each constraint
			NSNumber *priorityValue = [parameters valueForKey:SYMLLayoutVerticalPriority] ? : [parameters valueForKey:SYMLLayoutPriority];
			
			if(priorityValue && [priorityValue respondsToSelector:@selector(integerValue)]) {
				NSInteger priority = [priorityValue integerValue];
				
				for(NSLayoutConstraint *constraint in constraints)
					constraint.priority = priority;
			}
			
			[self addConstraints:constraints];
		}
	}
}


- (void)addConstraints:(NSArray *)constraints withPriority:(NSLayoutPriority)priority
{
	for(NSLayoutConstraint *constraint in constraints)
		constraint.priority = priority;
		
	[self addConstraints:constraints];
}



- (void)centerView:(NSView *)viewToCenter relativeToView:(NSView *)relativeToView xAxis:(BOOL)xAxis yAxis:(BOOL)yAxis
{
	if(!viewToCenter || !relativeToView) {
		NSLog(@"centerView:relativeToView:xAxis:yAxis: requires both a viewToCenter (%@) and relativeToView (%@)", viewToCenter, relativeToView);
		return;
	}
	
	if(xAxis) {
		NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:viewToCenter attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:relativeToView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
		[self addConstraint:constraint];
	}
	
	if(yAxis) {
		NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:viewToCenter attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:relativeToView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
		[self addConstraint:constraint];
	}
}


- (void)fillView:(NSView *)parentView
{
	if(parentView) {
		[parentView addConstraintsWithParamaters:@{
			SYMLLayoutHorizontalFormat : @"|[self]|",
			SYMLLayoutVerticalFormat : @"|[self]|",
			SYMLLayoutPriority : @(NSLayoutPriorityDefaultHigh),
			SYMLLayoutViews : NSDictionaryOfVariableBindings(self)
		}];
	} else {
		NSLog(@"%@ is trying to add constraints to fill a nil view", self);
	}
}


- (void)removeAllConstraints
{
	NSArray *currentConstraints = [self constraints];
	
	if([currentConstraints count] > 0)
		[self removeConstraints:currentConstraints];
}


@end
