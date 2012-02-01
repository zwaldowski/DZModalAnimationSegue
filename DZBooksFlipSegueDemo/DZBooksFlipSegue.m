//
//  DZBooksFlipSegue.m
//  DZBooksFlipSegueDemo
//
//  Created by Zachary Waldowski on 1/31/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZBooksFlipSegue.h"
#import <QuartzCore/QuartzCore.h>

static NSValue *degreeTransform(double degrees) {
	CATransform3D transform = CATransform3DMakeRotation(M_PI/180*degrees, 0.0f, 1.0f, 0.0);
	return [NSValue valueWithCATransform3D:transform];
}

@implementation DZBooksFlipSegue

+ (UIImage *)imageForView:(UIView *)aView {
    UIGraphicsBeginImageContextWithOptions(aView.frame.size, YES, [[UIScreen mainScreen] scale]);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)flipToViewController:(id)toController fromViewController:(id)fromController {
	CALayer *contentLayer = [CALayer layer];
	contentLayer.frame = [[toController view] bounds];
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
	
    oldLayer.contents = (id)[[self imageForView:[fromController view]] CGImage];
    newLayer.contents = (id)[[self imageForView:[toController view]] CGImage];
	rightLayer.contents = (__bridge id)[UIImage imageNamed:@"DZBooksFlipSegueSide"].CGImage;

	oldLayer.frame = newLayer.frame = transformLayer.bounds;
	oldLayer.zPosition = newLayer.zPosition = rightLayer.zPosition = 
	oldLayer.anchorPointZ = newLayer.anchorPointZ = animationDepth;
	
	rightLayer.frame = CGRectMake(CGRectGetMidX(transformLayer.bounds)+animationDepth, 0, -2*animationDepth, transformLayer.bounds.size.height);
	rightLayer.anchorPointZ = CGRectGetMidX(transformLayer.bounds);
    
	[[[toController view] layer] addSublayer:contentLayer];
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
	zAnim.timingFunctions = frontFlip.timingFunctions = 
	backFlip.timingFunctions = rightFlip.timingFunctions = [NSArray arrayWithObjects:
															[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
															[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
	
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
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:1.0f];
	[CATransaction setCompletionBlock:^{
		[contentLayer removeFromSuperlayer];
		[[UIApplication sharedApplication] performSelector:@selector(endIgnoringInteractionEvents) withObject:nil afterDelay:0.5];
		[[UIDevice currentDevice] performSelector:@selector(beginGeneratingDeviceOrientationNotifications) withObject:nil afterDelay:0.5];
	}];
	[oldLayer addAnimation:zAnim forKey:@"OldFlipZ"];
	[newLayer addAnimation:zAnim forKey:@"NewFlipZ"];
	[rightLayer addAnimation:zAnim forKey:@"RightFlipZ"];
	[oldLayer addAnimation:frontFlip forKey:@"OldFlip"];
	[newLayer addAnimation:backFlip forKey:@"NewFlip"];
	[rightLayer addAnimation:rightFlip forKey:@"RightFlip"];
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[CATransaction commit];
}

- (void)perform {
	UIModalPresentationStyle oldPresentationStyle = [self.destinationViewController modalPresentationStyle];

	[self.destinationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	
	[self.sourceViewController presentViewController:self.destinationViewController animated:NO completion:^{
		[DZBooksFlipSegue flipToViewController:self.destinationViewController fromViewController:self.sourceViewController];
		[self.destinationViewController setModalPresentationStyle:oldPresentationStyle];
	}];
}

@end
