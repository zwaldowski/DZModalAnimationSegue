//
//  CAAnimation+DZModalAnimationSegue.h
//  DZModalAnimationDemo
//
//  Created by Zachary Waldowski on 2/1/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (DZModalAnimationSegue)

@property (nonatomic, copy) void(^didStartBlock)(CAAnimation *);
@property (nonatomic, copy) void(^didStopBlock)(CAAnimation *, BOOL);

@end
