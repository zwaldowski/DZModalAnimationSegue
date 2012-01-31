//
//  DZMainViewController.h
//  DZBooksFlipSegueDemo
//
//  Created by Zachary Waldowski on 1/31/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZFlipsideViewController.h"

@interface DZMainViewController : UIViewController <DZFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
