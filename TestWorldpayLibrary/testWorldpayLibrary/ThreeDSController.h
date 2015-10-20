//
//  ThreeDSController.h
//  testWorldpayLibrary
//
//  Created by Vasilis Panagiotopoulos on 8/25/15.
//  Copyright (c) 2015 arx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreeDSController : UIViewController
@property (nonatomic) float price;
@property (nonatomic, retain) NSString *address, *city, *postalCode, *token, *name;
@end
