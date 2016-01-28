//
//  CustomGestureRecognizer.h
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomGestureRecognizer : UITapGestureRecognizer

@property (nonatomic) int cardRow;
@property (nonatomic) UIView *containerView;

@end
