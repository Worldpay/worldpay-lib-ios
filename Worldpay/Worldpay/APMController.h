//
//  APMController.h
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APMController : UIViewController

typedef void (^authorizeAPMOrderSuccess)(NSDictionary *responseDictionary);
typedef void (^authorizeAPMOrderFailure)(NSDictionary *responseDictionary, NSArray *errors);

@property (nonatomic) UIView *customToolbar;
@property (nonatomic) float price;

@property (nonatomic, strong) NSString *apmName;
@property (nonatomic, strong) NSString *customerOrderCode;
@property (nonatomic, strong) NSString *orderDescription;
@property (nonatomic, strong) NSDictionary *customerIdentifiers;
@property (nonatomic, strong) NSString *successUrl;
@property (nonatomic, strong) NSString *failureUrl;
@property (nonatomic, strong) NSString *cancelUrl;
@property (nonatomic, strong) NSString *pendingUrl;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, strong) NSString *settlementCurrency;
@property (nonatomic, strong) NSString *countryCode;

- (void)setAuthorizeAPMOrderBlockWithSuccess:(authorizeAPMOrderSuccess)success
                                     failure:(authorizeAPMOrderFailure)failure;

@end
