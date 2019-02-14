//
//  WorldpayAPMViewController.h
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Worldpay.h"

@interface WorldpayAPMViewController : UIViewController



/*!
 *  CUSTOM PARAMETERS:
 *  The developer can preset these parameters so they will be displayed as a read only parameters on the form (and not as inputs)
 */

@property (nonatomic, strong) UIToolbar *customToolbar;
@property (nonatomic, strong) UIButton *confirmPurchaseButton;

@property (nonatomic, copy) NSString *apmName;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *postcode;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *settlementCurrency;
@property (nonatomic, copy) NSString *successUrl;
@property (nonatomic, copy) NSString *cancelUrl;
@property (nonatomic, copy) NSString *failureUrl;
@property (nonatomic, copy) NSString *pendingUrl;
@property (nonatomic, copy) NSString *shopperLanguageCode;
@property (nonatomic, copy) NSString *swiftCode;
@property (nonatomic, copy) NSString *customerOrderCode;
@property (nonatomic, copy) NSString *orderDescription;

@property (nonatomic, strong) NSDictionary *customerIdentifiers;

@property (nonatomic, assign) CGFloat price;

typedef void (^createAPMOrderSuccess)(NSDictionary *responseDictionary);
typedef void (^createAPMOrderFailure)(NSDictionary *responseDictionary, NSArray *errors);

typedef NS_ENUM(NSUInteger, APMDetailsTheme) {
    APMDetailsThemeBlue,
    APMDetailsThemeRed,
    APMDetailsThemeYellow
};

@property (nonatomic, assign) APMDetailsTheme theme;

typedef NS_ENUM(NSUInteger, APMDetailsLoadingTheme) {
    APMDetailsLoadingThemeWhite,
    APMDetailsLoadingThemeBlack
};

@property (nonatomic, assign) APMDetailsLoadingTheme loadingTheme;

/*!
 *  Function to initialize APM Details with the default theme
 *
 *  @return self
 */
- (instancetype)init;


/*!
 *  Function to initialize APM Details of the "Edit APM" functionality view controller.
 *
 *  @param apmName        Choose the APM Name (this will automatically show/hide some fields)
 
 *  @return self ( the view controller)
 */
- (instancetype)initWithAPMName:(NSString *)apmName;


/*!
 *  Function to initialize APM Details of the "Edit APM" functionality view controller.
 *
 *  @param color          Choose any color
 *  @param loadingTheme   Choose the loading theme between white and black for the loading request to retrieve token
 *  @param apmName        Choose the APM Name (this will automatically show/hide some fields)
 
 *  @return self ( the view controller)
 */
- (instancetype)initWithColor:(UIColor *)color loadingTheme:(APMDetailsLoadingTheme)loadingTheme apmName:(NSString *)apmName;

/*!
 *  Function that adds a blackish transparent background with a loading indicator.
 */
- (void)addLoadingBackground;

/*!
 *  Function that remove the blackish transparent background.
 */
- (void)removeLoadingBackground;

/*!
 *  Function that sets the Send Request Tap Block
 *
 *  @param success Success block
 *  @param failure Failure block
 */
- (void)setCreateAPMOrderBlockWithSuccess:(createAPMOrderSuccess)success
                                  failure:(createAPMOrderFailure)failure;

@end
