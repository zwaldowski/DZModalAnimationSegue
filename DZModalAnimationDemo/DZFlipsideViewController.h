//
//  DZFlipsideViewController.h
//  DZModalAnimation
//
//  Created by Zachary Waldowski on 1/31/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DZFlipsideViewController;

@protocol DZFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(DZFlipsideViewController *)controller;
@end

@interface DZFlipsideViewController : UIViewController

@property (weak, nonatomic) IBOutlet id <DZFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
