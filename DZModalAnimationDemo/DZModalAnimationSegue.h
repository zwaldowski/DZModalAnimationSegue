//
//  DZBooksFlipSegue.h
//  DZModalAnimation
//
//  Created by Zachary Waldowski on 1/31/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	DZCustomModalAnimationCrossFade,
	DZCustomModalAnimationBooksFlip
} DZCustomModalAnimation;

@interface DZModalAnimationSegue : UIStoryboardSegue

@property (nonatomic) DZCustomModalAnimation animation;
@property (nonatomic) UIStatusBarStyle animationStatusBarStyle;

@end

@interface UIViewController (DZModalAnimationSegue)

- (void)dismissViewControllerWithCustomAnimation:(void (^)(void))completion;

@end