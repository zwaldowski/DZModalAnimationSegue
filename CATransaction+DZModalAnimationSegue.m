//
//  CATransaction+DZModalAnimationSegue.m
//  DZModalAnimation
//
//  Created by Zachary Waldowski on 2/1/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "CATransaction+DZModalAnimationSegue.h"

@implementation CATransaction (DZModalAnimationSegue)

+ (void)commitWithDuration:(NSTimeInterval)duration transactions:(void (^)(void))transactions {
	[self commitWithDuration:duration timingFunction:nil transactions:transactions completion:NULL];
}

+ (void)commitWithDuration:(NSTimeInterval)duration transactions:(void (^)(void))transactions completion:(void (^)(void))completion {
	[self commitWithDuration:duration timingFunction:nil transactions:transactions completion:completion];
}

+ (void)commitWithDuration:(NSTimeInterval)duration timingFunction:(CAMediaTimingFunction *)function transactions:(void (^)(void))transactions completion:(void (^)(void))completion {
	NSParameterAssert(transactions);
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
	if (function)
		[CATransaction setAnimationTimingFunction:function];
	if (completion)
		[CATransaction setCompletionBlock:completion];
	transactions();
	[CATransaction commit];
}


@end
