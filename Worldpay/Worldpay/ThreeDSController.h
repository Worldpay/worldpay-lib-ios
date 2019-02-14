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

@property (nonatomic, strong) UIView *customToolbar;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, copy  ) NSString *address, *city, *postalCode, *token, *name;
@property (nonatomic, strong) NSDictionary *customerIdentifiers;

- (void)setAuthorizeThreeDSOrderBlockWithSuccess:(threeDSOrderSuccess)success
                                         failure:(threeDSOrderFailure)failure;

@end
