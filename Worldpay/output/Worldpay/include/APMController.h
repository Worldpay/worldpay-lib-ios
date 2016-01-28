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

@property (nonatomic, retain) NSString *apmName;
@property (nonatomic, retain) NSString *customerOrderCode;
@property (nonatomic, retain) NSString *orderDescription;
@property (nonatomic, retain) NSDictionary *customerIdentifiers;
@property (nonatomic, retain) NSString *successUrl;
@property (nonatomic, retain) NSString *failureUrl;
@property (nonatomic, retain) NSString *cancelUrl;
@property (nonatomic, retain) NSString *pendingUrl;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *postalCode;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *currencyCode;
@property (nonatomic, retain) NSString *settlementCurrency;
@property (nonatomic, retain) NSString *countryCode;


- (void)setAuthorizeAPMOrderBlockWithSuccess:(authorizeAPMOrderSuccess)success
                                  failure:(authorizeAPMOrderFailure)failure;

@end
