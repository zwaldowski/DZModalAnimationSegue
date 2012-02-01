//
//  DZBooksFlipSegue.h
//  DZBooksFlipSegueDemo
//
//  Created by Zachary Waldowski on 1/31/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DZBooksFlipSegue : UIStoryboardSegue

+ (void)dismissByFlippingViewController:(UIViewController *)viewController completion:(void(^)(void))completion;

@end

@interface UIViewController (DZBooksFlipSegue)

- (void)dismissViewControllerByFlippingWithCompletion:(void (^)(void))completion;

@end