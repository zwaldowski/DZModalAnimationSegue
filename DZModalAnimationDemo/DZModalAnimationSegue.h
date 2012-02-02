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
	DZCustomModalAnimationBooksFlip,
	DZCustomModalAnimationCurl,   // up and down
	DZCustomModalAnimationFlip,   // up, down, left, right
	DZCustomModalAnimationMoveIn, // up, down, left, right
	DZCustomModalAnimationPush    // up, down, left, right
} DZCustomModalAnimation;

typedef enum {
	DZCustomModalAnimationSubtypeLeft,
	DZCustomModalAnimationSubtypeTop,
	DZCustomModalAnimationSubtypeBottom,
	DZCustomModalAnimationSubtypeRight,
} DZCustomModalAnimationSubtype;

@interface DZModalAnimationSegue : UIStoryboardSegue

@property (nonatomic) DZCustomModalAnimation animation;
@property (nonatomic) DZCustomModalAnimationSubtype animationSubtype;
@property (nonatomic) UIStatusBarStyle animationStatusBarStyle;

@end

@interface UIViewController (DZModalAnimationSegue)

- (void)dismissViewControllerWithCustomAnimation:(void (^)(void))completion;

@end