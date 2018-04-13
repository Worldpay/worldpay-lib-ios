//
//  SuccessPageViewController.h
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuccessPageViewController : UIViewController

/**
 *  Function that creates the custom Navigation Bar.
 */
- (void)createNavigationBar;

/**
 *  Function that creates and initiliazes the graphics user interface.
 */
- (void)initGUI;

/**
 *  Function that returns to MainPageViewController.
 *
 *  @param sender
 */
- (IBAction)home:(id)sender;

@end
