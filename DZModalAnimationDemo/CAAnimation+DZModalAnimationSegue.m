//
//  CAAnimation+DZModalAnimationSegue.m
//  DZModalAnimationDemo
//
//  Created by Zachary Waldowski on 2/1/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "CAAnimation+DZModalAnimationSegue.h"

@interface DZModalAnimationSegue_CAAnimationDelegate : NSObject

@property (nonatomic, copy) void(^didStartBlock)(CAAnimation *);
@property (nonatomic, copy) void(^didStopBlock)(CAAnimation *, BOOL);

@end

@implementation DZModalAnimationSegue_CAAnimationDelegate

@synthesize didStartBlock, didStopBlock;

- (void)animationDidStart:(CAAnimation *)animation {
	if (didStartBlock)
		didStartBlock(animation);
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
	if (didStopBlock)
		didStopBlock(animation, flag);
}

@end

@implementation CAAnimation (DZModalAnimationSegue)

- (void(^)(CAAnimation *))didStartBlock {
	if (![self.delegate isKindOfClass:[DZModalAnimationSegue_CAAnimationDelegate class]])
		return nil;
	
	return [self.delegate didStartBlock];
}

- (void)setDidStartBlock:(void (^)(CAAnimation *))didStartBlock {
	if (!self.delegate)
		self.delegate = [DZModalAnimationSegue_CAAnimationDelegate new];
	NSAssert([self.delegate isKindOfClass:[DZModalAnimationSegue_CAAnimationDelegate class]], @"CAAnimation isn't block backed: %@", self);
	
	[self.delegate setDidStartBlock:didStartBlock];
}

- (void(^)(CAAnimation *, BOOL))didStopBlock {
	if (![self.delegate isKindOfClass:[DZModalAnimationSegue_CAAnimationDelegate class]])
		return nil;
	
	return [self.delegate didStopBlock];
}

- (void)setDidStopBlock:(void (^)(CAAnimation *, BOOL))didStopBlock {
	if (!self.delegate)
		self.delegate = [DZModalAnimationSegue_CAAnimationDelegate new];
	NSAssert([self.delegate isKindOfClass:[DZModalAnimationSegue_CAAnimationDelegate class]], @"CAAnimation isn't block backed: %@", self);
	
	[self.delegate setDidStopBlock:didStopBlock];
}

@end
