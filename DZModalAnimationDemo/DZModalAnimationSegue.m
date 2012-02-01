//
//  DZModalAnimationSegue.m
//  DZModalAnimation
//
//  Created by Zachary Waldowski on 1/31/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZModalAnimationSegue.h"
#import "CATransaction+DZModalAnimationSegue.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static NSValue *degreeTransform(double degrees) {
	CATransform3D transform = CATransform3DMakeRotation(M_PI/180*degrees, 0.0f, 1.0f, 0.0);
	return [NSValue valueWithCATransform3D:transform];
}

static CGImageRef imageForView(UIView *aView) {
	UIGraphicsBeginImageContextWithOptions(aView.frame.size, YES, [[UIScreen mainScreen] scale]);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image CGImage];
}

static SEL selectorForAnimation(DZCustomModalAnimation animation) {
	switch (animation) {
		case DZCustomModalAnimationBooksFlip:
			return @selector(flipToView:fromView:completion:);
			break;
			
		default:
			return NULL;
			break;
	}
}

@interface UIViewController ()

@property (nonatomic) DZCustomModalAnimation customAnimation;
@property (nonatomic) UIStatusBarStyle animationStatusBarStyle;

@end

@interface DZModalAnimationSegue()

+ (void)performAnimation:(DZCustomModalAnimation)animation fromController:(id)from toController:(id)to reverse:(BOOL)reverse completion:(void(^)(void))completion;

+ (void)flipFrom:(UIViewController *)fromController to:(UIViewController *)toController reverse:(BOOL)reverse completion:(void(^)(void))completion;

@end

@implementation DZModalAnimationSegue

@synthesize animation, animationStatusBarStyle;

+ (void)performAnimation:(DZCustomModalAnimation)animation fromController:(id)from toController:(id)to reverse:(BOOL)reverse completion:(void(^)(void))completion {
	SEL selector;
	switch (animation) {
		case DZCustomModalAnimationBooksFlip:	selector = @selector(flipFrom:to:reverse:completion:); break;
		default:								selector = NULL; break;
	}
	
	NSMethodSignature *sig = [self methodSignatureForSelector:selector];
	if (!sig)
		return;
	
	NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
	[invo setTarget:self];
	[invo setSelector:selector];
	[invo setArgument:&from atIndex:2];
	[invo setArgument:&to atIndex:3];
	[invo setArgument:&reverse atIndex:4];
	[invo setArgument:&completion atIndex:5];
	[invo invoke];
}

+ (void)flipFrom:(UIViewController *)fromController to:(UIViewController *)toController reverse:(BOOL)reverse completion:(void(^)(void))completion {
	UIView *fromView = fromController.view;
	UIView *toView = toController.view;
	
	void(^animation)(void) = ^{
		CALayer *contentLayer = [CALayer layer];
		contentLayer.frame = [toView bounds];
		contentLayer.backgroundColor = [UIColor blackColor].CGColor;
		
		CATransformLayer *transformLayer = [CATransformLayer layer];
		transformLayer.frame = contentLayer.bounds;
		CATransform3D t = CATransform3DIdentity;
		t.m34 = -1.0 / 850.0;
		transformLayer.sublayerTransform = t;
		
		CGFloat animationDepth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? -80.0f : -40.0f;
		
		CALayer *oldLayer = [CALayer layer];
		CALayer *newLayer = [CALayer layer];
		CALayer *rightLayer = [CALayer layer];
		
		oldLayer.contents = (__bridge id)imageForView(fromView);
		newLayer.contents = (__bridge id)imageForView(toView);
		rightLayer.contents = (__bridge id)[UIImage imageNamed:@"DZBooksFlipSegueSide"].CGImage;
		
		oldLayer.frame = newLayer.frame = transformLayer.bounds;
		oldLayer.zPosition = newLayer.zPosition = rightLayer.zPosition = 
		oldLayer.anchorPointZ = newLayer.anchorPointZ = animationDepth;
		
		rightLayer.frame = CGRectMake(CGRectGetMidX(transformLayer.bounds)+animationDepth, 0, -2*animationDepth, transformLayer.bounds.size.height);
		rightLayer.anchorPointZ = CGRectGetMidX(transformLayer.bounds);
		
		[[toView layer] addSublayer:contentLayer];
		[contentLayer addSublayer:transformLayer];
		[transformLayer addSublayer:oldLayer];
		[transformLayer addSublayer:newLayer];
		[transformLayer addSublayer:rightLayer];
		
		CAKeyframeAnimation *zAnim     = [CAKeyframeAnimation animationWithKeyPath:@"zPosition"];
		CAKeyframeAnimation *frontFlip = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
		CAKeyframeAnimation *backFlip  = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
		CAKeyframeAnimation *rightFlip = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
		
		zAnim.keyTimes = frontFlip.keyTimes =
		backFlip.keyTimes = rightFlip.keyTimes = [NSArray arrayWithObjects:
												  [NSNumber numberWithDouble:0.0],
												  [NSNumber numberWithDouble:0.5],
												  [NSNumber numberWithDouble:1.0], nil];
		
		zAnim.values = [NSArray arrayWithObjects:
						[NSNumber numberWithDouble:animationDepth],
						[NSNumber numberWithDouble:4.75*animationDepth],
						[NSNumber numberWithDouble:animationDepth], nil];
		frontFlip.values = [NSArray arrayWithObjects:
							degreeTransform(0),
							degreeTransform(-90),
							degreeTransform(-180), nil];
		backFlip.values = [NSArray arrayWithObjects:
						   degreeTransform(180),
						   degreeTransform(90),
						   degreeTransform(0), nil];
		rightFlip.values = [NSArray arrayWithObjects:
							degreeTransform(-90),
							degreeTransform(-180),
							degreeTransform(90), nil];
		
		frontFlip.fillMode = backFlip.fillMode = rightFlip.fillMode = kCAFillModeBoth;
		frontFlip.removedOnCompletion = backFlip.removedOnCompletion = rightFlip.removedOnCompletion = NO;
		
		CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[CATransaction commitWithDuration:1.0 timingFunction:timingFunction transactions:^{
			[oldLayer addAnimation:zAnim forKey:@"OldFlipZ"];
			[newLayer addAnimation:zAnim forKey:@"NewFlipZ"];
			[rightLayer addAnimation:zAnim forKey:@"RightFlipZ"];
			[oldLayer addAnimation:frontFlip forKey:@"OldFlip"];
			[newLayer addAnimation:backFlip forKey:@"NewFlip"];
			[rightLayer addAnimation:rightFlip forKey:@"RightFlip"];
			[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
			[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
		} completion:^{
			[contentLayer removeFromSuperlayer];
			[[UIApplication sharedApplication] performSelector:@selector(endIgnoringInteractionEvents) withObject:nil afterDelay:0.2];
			[[UIDevice currentDevice] performSelector:@selector(beginGeneratingDeviceOrientationNotifications) withObject:nil afterDelay:0.5];
			if (completion)
				completion();
		}];
	};
	
	if (reverse) {
		[fromController dismissViewControllerAnimated:NO completion:animation];
	} else {
		[fromController presentViewController:toController animated:NO completion:animation];
	}
}

- (void)perform {
	UIModalPresentationStyle oldPresentationStyle = [self.destinationViewController modalPresentationStyle];
	UIStatusBarStyle oldStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	
	[self.destinationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
	[self.destinationViewController setCustomAnimation:self.animation];
	[[UIApplication sharedApplication] setStatusBarStyle:self.animationStatusBarStyle animated:YES];
	
	[DZModalAnimationSegue performAnimation:self.animation fromController:self.sourceViewController toController:self.destinationViewController reverse:NO completion:^{
		[self.destinationViewController setModalPresentationStyle:oldPresentationStyle];
		[[UIApplication sharedApplication] setStatusBarStyle:oldStatusBarStyle animated:YES];
	}];
}

@end

@implementation UIViewController (DZModalAnimationSegue)

static char DZCustomAnimationKey;
static char DZCustomAnimationStatusBarKey;

- (void)dismissViewControllerWithCustomAnimation:(void (^)(void))completion {
	UIViewController *fromViewController = self.presentedViewController ?: self;
	UIViewController *toViewController = self.presentingViewController ?: self;
	
	UIModalPresentationStyle oldPresentationStyle = [fromViewController modalPresentationStyle];
	UIStatusBarStyle oldStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	
	[fromViewController setModalPresentationStyle:UIModalPresentationFullScreen];
	[[UIApplication sharedApplication] setStatusBarStyle:self.animationStatusBarStyle animated:YES];

	[DZModalAnimationSegue performAnimation:fromViewController.customAnimation fromController:fromViewController toController:toViewController reverse:YES completion:^{
		[fromViewController setModalPresentationStyle:oldPresentationStyle];
		[[UIApplication sharedApplication] setStatusBarStyle:oldStatusBarStyle animated:YES];
	}];
}

- (void)setAnimationStatusBarStyle:(UIStatusBarStyle)style {
	objc_setAssociatedObject(self, &DZCustomAnimationStatusBarKey, [NSNumber numberWithInteger:style], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIStatusBarStyle)animationStatusBarStyle {
	return [objc_getAssociatedObject(self, &DZCustomAnimationStatusBarKey) integerValue];
}

- (void)setCustomAnimation:(DZCustomModalAnimation)customAnimation {
	objc_setAssociatedObject(self, &DZCustomAnimationKey, [NSNumber numberWithInteger:customAnimation], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DZCustomModalAnimation)customAnimation {
	return [objc_getAssociatedObject(self, &DZCustomAnimationKey) integerValue];
}

@end