//
//  WorldpayAPMViewController.h
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Worldpay.h"

@interface WorldpayAPMViewController : UIViewController <UITextFieldDelegate>



/*!
 *  CUSTOM PARAMETERS:
 *  The developer can preset these parameters so they will be displayed as a read only parameters on the form (and not as inputs)
 */

@property (nonatomic) UIToolbar *customToolbar;
@property (nonatomic) UIButton *confirmPurchaseButton;

@property (nonatomic) NSString *apmName;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *postcode;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *countryCode;
@property (nonatomic) NSString *currency;
@property (nonatomic) NSString *settlementCurrency;
@property (nonatomic) NSString *successUrl;
@property (nonatomic) NSString *cancelUrl;
@property (nonatomic) NSString *failureUrl;
@property (nonatomic) NSString *pendingUrl;
@property (nonatomic) NSString *shopperLanguageCode;
@property (nonatomic) NSString *swiftCode;
@property (nonatomic) NSString *customerOrderCode;
@property (nonatomic) NSString *orderDescription;
@property (nonatomic) NSDictionary *customerIdentifiers;

@property (nonatomic) float price;

typedef void (^createAPMOrderSuccess)(NSDictionary *responseDictionary);
typedef void (^createAPMOrderFailure)(NSDictionary *responseDictionary, NSArray *errors);

typedef enum {
    APMDetailsThemeBlue,
    APMDetailsThemeRed,
    APMDetailsThemeYellow
} APMDetailsTheme;

@property (nonatomic) APMDetailsTheme theme;

typedef enum {
    APMDetailsLoadingThemeWhite,
    APMDetailsLoadingThemeBlack
} APMDetailsLoadingTheme;

@property (nonatomic) APMDetailsLoadingTheme loadingTheme;

/*!
 *  Function to initialize APM Details with the default theme
 *
 *  @return self
 */
-(id)init;


/*!
 *  Function to initialize APM Details of the "Edit APM" functionality view controller.
 *
 *  @param apmName        Choose the APM Name (this will automatically show/hide some fields)
 
 *  @return self ( the view controller)
 */
-(id)initWithAPMName:(NSString *)apmName;

    
/*!
 *  Function to initialize APM Details of the "Edit APM" functionality view controller.
 *
 *  @param color          Choose any color
 *  @param loadingTheme   Choose the loading theme between white and black for the loading request to retrieve token
 *  @param apmName        Choose the APM Name (this will automatically show/hide some fields)

 *  @return self ( the view controller)
 */
-(id)initWithColor:(UIColor *)color loadingTheme:(APMDetailsLoadingTheme)loadingTheme apmName:(NSString *)apmName;

/*!
 *  Function that adds a blackish transparent background with a loading indicator.
 */
-(void)addLoadingBackground;

/*!
 *  Function that remove the blackish transparent background.
 */
-(void)removeLoadingBackground;

/*!
 *  Function that sets the Send Request Tap Block
 *
 *  @param success
 *  @param failure 
 */
-(void)setCreateAPMOrderBlockWithSuccess:(createAPMOrderSuccess)success
                                failure:(createAPMOrderFailure)failure;

@end
