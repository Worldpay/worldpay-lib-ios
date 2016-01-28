//
//  ThreeDSController.h
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreeDSController : UIViewController


typedef void (^threeDSOrderSuccess)(NSDictionary *responseDictionary);
typedef void (^threeDSOrderFailure)(NSDictionary *responseDictionary, NSArray *errors);

@property (nonatomic) UIView *customToolbar;
@property (nonatomic) float price;
@property (nonatomic, retain) NSString *address, *city, *postalCode, *token, *name;
@property (nonatomic) NSDictionary *customerIdentifiers;


- (void)setAuthorizeThreeDSOrderBlockWithSuccess:(threeDSOrderSuccess)success
                                         failure:(threeDSOrderFailure)failure;
    
@end
