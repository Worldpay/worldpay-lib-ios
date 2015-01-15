//
//  Worldpay.h
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>

#define api_version @"v1"
#define api_path @"https://api.worldpay.com/v1/"


@interface Worldpay : NSObject {
    
    NSString *WorldpayClientKey;
    BOOL WorldpayReusable;
    int WorldpayTimeout;
    
}

typedef void (^requestUpdateTokenSuccess)(int code, NSDictionary *responseDictionary);
typedef void (^requestTokenFailure)(NSDictionary *responseDictionary, NSArray *errors);
typedef void (^updateTokenFailure)(NSDictionary *responseDictionary, NSArray *errors);

typedef enum {
    WorldpayValidationTypeBasic,
    WorldpayValidationTypeAdvanced,
    validation_types
} WorldpayValidationType;

/*!
 *  Property to set the validation type (WorldpayValidationTypeBasic or WorldpayValidationTypeAdvanced)
 */
@property (nonatomic) WorldpayValidationType validationType;


/*!
 *  It defines a static variable (but only global to this translation unit) which is then initialized once and only once in sharedInstance. The way we ensure that it’s only created once is by using the dispatch_once method from Grand Central Dispatch (GCD). Singleton Pattern is being used here.
 *
 *  @returns a new Worldpay object if it hasn't been created or returns the Worldpay object if it exists
 */
+ (id) sharedInstance;


/*!
 *  Function that sets the client Key which is used for API calls made directly from your customer's browser
 *
 *  @param clientKey the client Key that is used to get token : NSString
 */
- (void)setClientKey:(NSString *)clientKey;

/*!
 *  Worldpay allows you to store card details so you can charge a card multiple times. You can use this to offer your customers card-on-file payment or a recurring payment
 *
 *  @param reusable YES or NO : BOOL
 */
- (void)setReusable:(BOOL)reusable;

/*!
 *  Function that validates the card credentials and then makes the request to create token
 *
 *  @param holderName      First and Last name of the card's owner : NSString  ( MANDATORY )
 *  @param cardNumber      Card number : NSString ( MANDATORY )
 *  @param expirationDate  The expiration of the card in the (MM/YY) format : NSString ( MANDATORY )
 *  @param CVC             The 3 or 4 digits of the Card Veridication Code : NSString ( OPTIONAL )
 *  @param success         On success returning status : long , responseData
 *  @param failure         On failure returning status : NSDictionary and NSArray of errors
 */
- (void)createTokenWithNameOnCard:(NSString *)holderName
                       cardNumber:(NSString *)cardNumber
                  expirationMonth:(NSString *)expirationMonth
                   expirationYear:(NSString *)expirationYear
                              CVC:(NSString *)CVC
                          success:(requestUpdateTokenSuccess)success
                          failure:(requestTokenFailure)failure;

/*!
 *  Function that makes the request to update the token
 *
 *  @param token           The token : NSString ( MANDATORY )
 *  @param CVC             The 3 or 4 digits of Card Veridication Code : NSString ( MANDATORY )
 *  @param success         On success returning status : long , responseData
 *  @param failure         On failure returning status : NSDictionary and NSArray of errors
 */
- (void)reuseToken:(NSString *)token
           withCVC:(NSString *)CVC
           success:(requestUpdateTokenSuccess)success
           failure:(updateTokenFailure)failure;

/*!
 *  Function that shows a dialog and asks for the CVC, then it calls reuseToken:withCVC:success:failure:
 *
 *  @param success         On success returning status : long , responseData
 *  @param failure         On failure returning status : NSDictionary and NSArray of errors
 */

-(void)showCVCModalWithParentView:(UIView *)parentView
                            token:(NSString *)token
                          success:(requestUpdateTokenSuccess)success
                            error:(updateTokenFailure)failure;

/*!
 *  Function to strip card number by removing the " " (white spaces) and removing the "-" dashes
 *
 *  @param cardNumber is the cardNumber : NSString
 *
 *  @return the card Number stripped : NSString
 */
- (NSString *)stripCardNumberWithCardNumber:(NSString *)cardNumber;

/*!
 *  Function to validate Card's Number is Basic
 *
 *  @param cardNumber is the Card Number : NSString
 *
 *  @return YES or NO
 */
- (BOOL)validateCardNumberBasicWithCardNumber:(NSString *)cardNumber;

/*!
 *  Function to validate Card's Number is Advanced
 *
 *  @param cardNumber is the Card Number : NSString
 *
 *  @return YES or NO
 */
- (BOOL)validateCardNumberAdvancedWithCardNumber:(NSString *)cardNumber;

/*!
 *  Function to validate Card Expiration Date. Year can be in YY or YYYY format
 *
 *  @param month is the month the card expires : int
 *  @param year  is the year the card expires : int
 *
 *  @return YES or NO
 */
- (BOOL)validateCardExpiryWithMonth:(int)month
                               year:(int)year;

/*!
 *  Function to validate the CVC (Card Verification Code)
 *
 *  @param cvc is the three-digit number : NSString
 *
 *  @return YES or NO
 */
- (BOOL)validateCardCVCWithNumber:(NSString *)cvc;

/*!
 *  Function to validate the Holder's Name
 *
 *  @param holderName is the Holder's Name : NSString
 *
 *  @return YES or NO
 */
- (BOOL)validateCardHolderNameWithName:(NSString *)holderName;

/*!
 *  Function that validates cvc and token. It is called before the updateToken function
 *
 *  @param cvc is the three-digit number : NSString
 *  @param token is required to make payments
 *
 *  @return an array of errors: 1 -> Problem with Card Expiration Date, 2 -> Problem with Card Number, 3 -> Problem with Name on Card ( holder name ), 4 -> Problem with CVC ( Card Verification Code )
 */
- (NSArray *)validateCardDetailsWithCVC:(NSString *)CVC
                                  token:(NSString *)token;

/*!
 *  Function that validates holderName, cardNumber, expirationDate and CVC. It is called before the requestToken function.
 *
 *  @param holderName      First and Last name of the card's owner : NSString  ( MANDATORY )
 *  @param cardNumber      card number : NSString ( MANDATORY )
 *  @param expirationDate  The expiration of the card in the (MM/YY) format : NSString ( MANDATORY )
 *  @param CVC             The 3 or 4 digits of the Card Veridication Code : NSString ( OPTIONAL )
 *
 *  @return an array of errors: 1 -> Problem with Card Expiration Date, 2 -> Problem with Card Number, 3 -> Problem with Name on Card ( holder name ), 4 -> Problem with CVC ( Card Verification Code )
 */
-(NSArray *)validateCardDetailsWithHolderName:(NSString *)holderName
                                   cardNumber:(NSString *)cardNumber
                              expirationMonth:(NSString *)expirationMonth
                               expirationYear:(NSString *)expirationYear
                                          CVC:(NSString *)CVC;


/*!
 *  Returns the type of the card
 *
 *  @param cardNumber The card number
 *
 *  @return The type of the card
 */
- (NSString *)cardType:(NSString *)cardNumber;

@end
