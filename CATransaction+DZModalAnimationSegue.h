//
//  CATransaction+DZModalAnimationSegue.h
//  DZModalAnimation
//
//  Created by Zachary Waldowski on 2/1/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CATransaction (DZModalAnimationSegue)

+ (void)commitWithDuration:(NSTimeInterval)duration transactions:(void (^)(void))transactions;
+ (void)commitWithDuration:(NSTimeInterval)duration transactions:(void (^)(void))transactions completion:(void (^)(void))completion;
+ (void)commitWithDuration:(NSTimeInterval)duration timingFunction:(CAMediaTimingFunction *)function transactions:(void (^)(void))transactions completion:(void (^)(void))completion;



@end
