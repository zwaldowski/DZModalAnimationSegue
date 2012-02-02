//
//  DZModalAnimationSegue.m
//  DZModalAnimation
//
//  Created by Zachary Waldowski on 1/31/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZModalAnimationSegue.h"
#import "CATransaction+DZModalAnimationSegue.h"
#import "CAAnimation+DZModalAnimationSegue.h"
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

@interface UIViewController ()

@property (nonatomic, setter = dz_setCustomAnimation:) DZCustomModalAnimation dz_customAnimation;
@property (nonatomic, setter = dz_setCustomAnimationSubtype:) DZCustomModalAnimationSubtype dz_customAnimationSubtype;
@property (nonatomic, setter = dz_setCustomAnimationStatusBarStyle:) UIStatusBarStyle dz_customAnimationStatusBarStyle;

@end

@interface DZModalAnimationSegue()

+ (void)performAnimation:(DZCustomModalAnimation)animation withSubtype:(DZCustomModalAnimationSubtype)subtype fromView:(UIView *)from toView:(UIView *)to reverse:(BOOL)reverse completion:(void(^)(void))completion;

@end

@implementation DZModalAnimationSegue

@synthesize animation, animationStatusBarStyle, animationSubtype;

+ (void)booksFlipFrom:(UIView *)fromView to:(UIView *)toView reverse:(BOOL)reverse completion:(void(^)(void))completion {
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
	} completion:^{
		[contentLayer removeFromSuperlayer];
		if (completion)
			completion();
	}];
}

+ (void)viewTransitionFrom:(UIView *)fromView to:(UIView *)toView duration:(NSTimeInterval)length openAnimation:(UIViewAnimationOptions)openOptions closeAnimation:(UIViewAnimationOptions)closeOptions reverse:(BOOL)reverse completion:(void(^)(void))completion {
	[toView.superview addSubview:fromView];
	UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionShowHideTransitionViews;
	if (reverse)
		options |= closeOptions;
	else
		options |= openOptions;
	[UIView transitionFromView:fromView toView:toView duration:length options:options completion:^(BOOL finished) {
		if (completion)
			completion();
	}];
}

+ (void)fadeFrom:(UIView *)fromView to:(UIView *)toView reverse:(BOOL)reverse completion:(void(^)(void))completion {
	[self viewTransitionFrom:fromView to:toView duration:(1./3.) openAnimation:UIViewAnimationOptionTransitionCrossDissolve closeAnimation:UIViewAnimationOptionTransitionCrossDissolve reverse:reverse completion:completion];
}

+ (void)curlFrom:(UIView *)fromView to:(UIView *)toView reverse:(BOOL)reverse subtype:(DZCustomModalAnimationSubtype)subtype completion:(void(^)(void))completion {
	UIViewAnimationOptions subtypeOptionsOpen = (subtype == DZCustomModalAnimationSubtypeBottom) ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown;
	UIViewAnimationOptions subtypeOptionsClose = (subtype == DZCustomModalAnimationSubtypeBottom) ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp;
	[self viewTransitionFrom:fromView to:toView duration:1.0 openAnimation:subtypeOptionsOpen closeAnimation:subtypeOptionsClose reverse:reverse completion:completion];
}

+ (void)flipFrom:(UIView *)fromView to:(UIView *)toView reverse:(BOOL)reverse subtype:(DZCustomModalAnimationSubtype)subtype completion:(void(^)(void))completion {
	UIViewAnimationOptions subtypeOptionsOpen, subtypeOptionsClose;
	switch (subtype) {
		case DZCustomModalAnimationSubtypeLeft:
			subtypeOptionsOpen = UIViewAnimationOptionTransitionFlipFromLeft;
			subtypeOptionsClose = UIViewAnimationOptionTransitionFlipFromRight;
			break;
		case DZCustomModalAnimationSubtypeTop:
			subtypeOptionsOpen = UIViewAnimationOptionTransitionFlipFromTop;
			subtypeOptionsClose = UIViewAnimationOptionTransitionFlipFromBottom;
			break;
		case DZCustomModalAnimationSubtypeRight:
			subtypeOptionsOpen = UIViewAnimationOptionTransitionFlipFromRight;
			subtypeOptionsClose = UIViewAnimationOptionTransitionFlipFromLeft;
			break;
		case DZCustomModalAnimationSubtypeBottom:
			subtypeOptionsOpen = UIViewAnimationOptionTransitionFlipFromBottom;
			subtypeOptionsClose = UIViewAnimationOptionTransitionFlipFromTop;
			break;
	}
	[self viewTransitionFrom:fromView to:toView duration:1.0 openAnimation:subtypeOptionsOpen closeAnimation:subtypeOptionsClose reverse:reverse completion:completion];
}

+ (void)layerTransitionFrom:(UIView *)fromView to:(UIView *)toView reverse:(BOOL)reverse animationType:(NSString *)animationType subtype:(DZCustomModalAnimationSubtype)subtype completion:(void(^)(void))completion {
	CALayer *contentLayer = [CALayer layer];
	contentLayer.frame = [toView bounds];
	contentLayer.backgroundColor = [UIColor blackColor].CGColor;
	
	CALayer *oldLayer = [CALayer layer];
	CALayer *newLayer = [CALayer layer];
	
	oldLayer.contents = (__bridge id)imageForView(fromView);
	newLayer.contents = (__bridge id)imageForView(toView);
	
	oldLayer.frame = newLayer.frame = contentLayer.bounds;
	
	[[toView layer] addSublayer:contentLayer];
	[contentLayer addSublayer:oldLayer];
	[contentLayer addSublayer:newLayer];
	
	CATransition *transition = [CATransition animation];
	
	NSString *animationSubtype = nil;
	switch (subtype) {
		case DZCustomModalAnimationSubtypeLeft:   animationSubtype = reverse ? kCATransitionFromRight : kCATransitionFromLeft; break;
		case DZCustomModalAnimationSubtypeTop:    animationSubtype = reverse ? kCATransitionFromBottom : kCATransitionFromTop; break;
		case DZCustomModalAnimationSubtypeBottom: animationSubtype = reverse ? kCATransitionFromTop : kCATransitionFromBottom; break;
		case DZCustomModalAnimationSubtypeRight:  animationSubtype = reverse ? kCATransitionFromLeft : kCATransitionFromRight; break;
	}
	
	transition.type = animationType;
	transition.subtype = animationSubtype;
	transition.fillMode = kCAFillModeForwards;
	transition.removedOnCompletion = YES;
	transition.duration = 1.0;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.didStopBlock = ^(CAAnimation *animation, BOOL didStop) {
		[contentLayer removeFromSuperlayer];
		if (completion)
			completion();
	};
	
	[newLayer addAnimation:transition forKey:nil];
}

+ (void)moveInFrom:(UIView *)fromView to:(UIView *)toView reverse:(BOOL)reverse subtype:(DZCustomModalAnimationSubtype)subtype completion:(void(^)(void))completion {
	[self layerTransitionFrom:fromView to:toView reverse:reverse animationType:kCATransitionMoveIn subtype:subtype completion:completion];
}

+ (void)pushFrom:(UIView *)fromView to:(UIView *)toView reverse:(BOOL)reverse subtype:(DZCustomModalAnimationSubtype)subtype completion:(void(^)(void))completion {
	[self layerTransitionFrom:fromView to:toView reverse:reverse animationType:kCATransitionPush subtype:subtype completion:completion];
}

+ (void)performAnimation:(DZCustomModalAnimation)animation withSubtype:(DZCustomModalAnimationSubtype)subtype fromView:(UIView *)from toView:(UIView *)to reverse:(BOOL)reverse completion:(void(^)(void))completion {
	BOOL hasSubtype = ((animation != DZCustomModalAnimationCrossFade) && (animation != DZCustomModalAnimationBooksFlip));
	
	SEL selector;
	switch (animation) {
		case DZCustomModalAnimationCrossFade:  selector = @selector(fadeFrom:to:reverse:completion:); break;
		case DZCustomModalAnimationBooksFlip:  selector = @selector(booksFlipFrom:to:reverse:completion:); break;
		case DZCustomModalAnimationCurl:       selector = @selector(curlFrom:to:reverse:completion:); break;
		case DZCustomModalAnimationFlip:       selector = @selector(flipFrom:to:reverse:subtype:completion:); break;
		case DZCustomModalAnimationMoveIn:     selector = @selector(moveInFrom:to:reverse:subtype:completion:); break;
		case DZCustomModalAnimationPush:       selector = @selector(pushFrom:to:reverse:subtype:completion:); break;
		default:							   selector = NULL; break;
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
	if (hasSubtype)
		[invo setArgument:&subtype atIndex:5];
	[invo setArgument:&completion atIndex:hasSubtype ? 6 : 5];
	[invo invoke];
}

- (void)perform {
	UIModalPresentationStyle oldPresentationStyle = [self.destinationViewController modalPresentationStyle];
	UIStatusBarStyle oldStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	
	[self.destinationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
	[self.destinationViewController dz_setCustomAnimation:self.animation];
	[[UIApplication sharedApplication] setStatusBarStyle:self.animationStatusBarStyle animated:YES];
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[self.sourceViewController presentViewController:self.destinationViewController animated:NO completion:^{
		[DZModalAnimationSegue performAnimation:self.animation withSubtype:self.animationSubtype fromView:[self.sourceViewController view] toView:[self.destinationViewController view] reverse:NO completion:^{
			[self.destinationViewController setModalPresentationStyle:oldPresentationStyle];
			[[UIApplication sharedApplication] setStatusBarStyle:oldStatusBarStyle animated:YES];
			[[UIApplication sharedApplication] performSelector:@selector(endIgnoringInteractionEvents) withObject:nil afterDelay:0.2];
			[[UIDevice currentDevice] performSelector:@selector(beginGeneratingDeviceOrientationNotifications) withObject:nil afterDelay:0.5];
		}];
	}];
}

@end

@implementation UIViewController (DZModalAnimationSegue)

static char DZCustomAnimationKey;
static char DZCustomAnimationSubtypeKey;
static char DZCustomAnimationStatusBarKey;

- (void)dismissViewControllerWithCustomAnimation:(void (^)(void))completion {
	UIViewController *fromViewController = self.presentedViewController ?: self;
	UIViewController *toViewController = self.presentingViewController ?: self;
	
	UIModalPresentationStyle oldPresentationStyle = [fromViewController modalPresentationStyle];
	UIStatusBarStyle oldStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	
	[fromViewController setModalPresentationStyle:UIModalPresentationFullScreen];
	[[UIApplication sharedApplication] setStatusBarStyle:self.dz_customAnimationStatusBarStyle animated:YES];
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[fromViewController dismissViewControllerAnimated:NO completion:^{
		[DZModalAnimationSegue performAnimation:fromViewController.dz_customAnimation withSubtype:fromViewController.dz_customAnimationSubtype fromView:fromViewController.view toView:toViewController.view reverse:YES completion:^{
			[fromViewController setModalPresentationStyle:oldPresentationStyle];
			[[UIApplication sharedApplication] setStatusBarStyle:oldStatusBarStyle animated:YES];
			[[UIApplication sharedApplication] performSelector:@selector(endIgnoringInteractionEvents) withObject:nil afterDelay:0.2];
			[[UIDevice currentDevice] performSelector:@selector(beginGeneratingDeviceOrientationNotifications) withObject:nil afterDelay:0.5];
		}];
	}];
}

- (void)dz_setCustomAnimation:(DZCustomModalAnimation)animation {
	objc_setAssociatedObject(self, &DZCustomAnimationKey, [NSNumber numberWithInteger:animation], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DZCustomModalAnimation)dz_customAnimation {
	return [objc_getAssociatedObject(self, &DZCustomAnimationKey) integerValue];
}

- (void)dz_setCustomAnimationSubtype:(DZCustomModalAnimationSubtype)type {
	objc_setAssociatedObject(self, &DZCustomAnimationSubtypeKey, [NSNumber numberWithInteger:type], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DZCustomModalAnimationSubtype)dz_customAnimationSubtype {
	return [objc_getAssociatedObject(self, &DZCustomAnimationSubtypeKey) integerValue];
}

- (void)dz_setCustomAnimationStatusBarStyle:(DZCustomModalAnimation)style {
	objc_setAssociatedObject(self, &DZCustomAnimationStatusBarKey, [NSNumber numberWithInteger:style], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIStatusBarStyle)dz_customAnimationStatusBarStyle {
	return [objc_getAssociatedObject(self, &DZCustomAnimationStatusBarKey) integerValue];
}

@end