//
//  WorldpayCardViewController.h
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

@import UIKit;

#import "Worldpay.h"

@interface WorldpayCardViewController : UIViewController

typedef void (^requestTokenSuccess)(NSDictionary *responseDictionary);
typedef void (^requestTokenFailure)(NSDictionary *responseDictionary, NSArray *errors);

typedef NS_ENUM(NSUInteger, CardDetailsTheme) {
    CardDetailsThemeBlue,
    CardDetailsThemeRed,
    CardDetailsThemeYellow
};

@property (nonatomic, assign) CardDetailsTheme theme;

typedef NS_ENUM(NSUInteger, CardDetailsLoadingTheme) {
    CardDetailsLoadingThemeWhite,
    CardDetailsLoadingThemeBlack
};

@property (nonatomic, assign) CardDetailsLoadingTheme loadingTheme;

typedef NS_ENUM(NSUInteger, CardDetailsTextField) {
    CardDetailsTextFieldFirstName,
    CardDetailsTextFieldLastName,
    CardDetailsTextFieldCardNumber,
    CardDetailsTextFieldExpiry,
    CardDetailsTextFieldCVC
};

/*!
 *  Function to initialize Card Details with the default theme
 *
 *  @return self
 */
- (instancetype)init;

/*!
 *  Function to initialize Card Details of the "add card" functionallity view controller.
 *
 *  @param color          Choose any color
 *  @param loadingTheme   Choose the loading theme between white and black for the loading request to retrieve token
 *
 *  @return self ( the view controller)
 */
- (instancetype)initWithColor:(UIColor *)color loadingTheme:(CardDetailsLoadingTheme)loadingTheme;

/*!
 *  Function to choose which textField to shake to indicate the error field.
 *
 *  @param textField the one that is going to be shaked and colored red.
 */
- (void)shakeTextField:(CardDetailsTextField)textField;

/*!
 *  Function that calls the warning view regarding the SSL encryption after we validate the card details and before we make the request
 */
- (void)showWarningView;


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
- (void)setSaveButtonTapBlockWithSuccess:(requestTokenSuccess)success
                                 failure:(requestTokenFailure)failure;

@end
