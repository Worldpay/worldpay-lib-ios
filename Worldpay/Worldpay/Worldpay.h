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

#define api_url @"https://api.worldpay.com/v1/"

@interface Worldpay : NSObject {
    
    NSString *WorldpayClientKey;
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
 *  Property that sets the Client Key which is used for API calls made directly from your customer's browser
 */
@property (nonatomic, retain) NSString *clientKey;

/*!
 *  Property that sets the Service Key which is used for some API calls like order API
 */
@property (nonatomic, retain) NSString *serviceKey;

/*!
 *  Worldpay allows you to store card details so you can charge a card multiple times. You can use this to offer your customers card-on-file payment or a recurring payment
 */
@property (nonatomic) BOOL reusable;

/*!
 *  Authorisations can be used if you want to ring-fence the funds on a customer's bank account days or weeks before making the actual payment. A typical use case for this is hotel reservations or car rentals.
 */
@property (nonatomic) BOOL authorizeOnly;


/*!
 *  Property that sets the Token Type (card / apm) used for apm orders
 */
@property (nonatomic, retain) NSString *tokenType;

/*!
 *  It defines a static variable (but only global to this translation unit) which is then initialized once and only once in sharedInstance. The way we ensure that it’s only created once is by using the dispatch_once method from Grand Central Dispatch (GCD). Singleton Pattern is being used here.
 *
 *  @returns a new Worldpay object if it hasn't been created or returns the Worldpay object if it exists
 */
+ (Worldpay *) sharedInstance;

/*!
 *  Worldpay allows you to store card details so you can charge a card multiple times. You can use this to offer your customers card-on-file payment or a recurring payment
 *
 *  @param reusable YES or NO : BOOL
 */
- (void)setReusable:(BOOL)reusable;


/*!
 *  Returns the API URL based on environment property
 *
 */
- (NSString *)APIStringURL;

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
 *  Function that validates the APM data and then makes the request to create a APM token
 *
 *  @param apmName              Name of the Alternative Payment Method (APM) : NSString  ( MANDATORY )
 *  @param countryCode          Country Code format : NSString ( MANDATORY )
 *  @param apmFields            Extra fields related with the APM provided : NSDictionary ( OPTIONAL )
 *  @param shopperLanguageCode  Shopper Language Code : NSString ( OPTIONAL )
 *  @param success              On success returning status : long , responseData
 *  @param failure              On failure returning status : NSDictionary and NSArray of errors
 */
- (void)createAPMTokenWithAPMName:(NSString *)apmName
                      countryCode:(NSString *)countryCode
                        apmFields:(NSDictionary *)apmFields
              shopperLanguageCode:(NSString *)shopperLanguageCode
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
                            error:(updateTokenFailure)failure __deprecated;

/*!
 *  Function that shows a dialog and asks for the CVC, then it calls reuseToken:withCVC:success:failure:. It also provides a beforeRequest callback (useful if you want to show a custom loader to your app)
 *
 *  @param success         On success returning status : long , responseData
 *  @param failure         On failure returning status : NSDictionary and NSArray of errors
 */

-(void)showCVCModalWithParentView:(UIView *)parentView
                            token:(NSString *)token
                          success:(requestUpdateTokenSuccess)success
                    beforeRequest:(void (^)(void))beforeRequest
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
 *  Function that validates apmName & countryCode. It is called before the requestToken function (APM).
 *
 *  @param apmName is the name of the Alternative Payment Method : NSString
 *  @param countryCode is the country code : NSString
 *
 *  @return an array of errors: 1 -> Problem with APM Name, 2 -> Problem with Country Code
 */
-(NSArray *)validateAPMDetailsWithAPMName:(NSString *)apmName
                              countryCode:(NSString *)countryCode;

/*!
 *  Function to validate the APM Name
 *
 *  @param apmName is the name of the Alternative Payment Method : NSString
 *
 *  @return YES or NO
 */
-(BOOL)validateAPMNameWithName:(NSString *)apmName;

/*!
 *  Function to validate the Country Code
 *
 *  @param countryCode is the country code : NSString
 *
 *  @return YES or NO
 */
-(BOOL)validateCountryCodeWithCode:(NSString *)countryCode;


/*!
 *  Returns the type of the card
 *
 *  @param cardNumber The card number
 *
 *  @return The type of the card
 */
- (NSString *)cardType:(NSString *)cardNumber;

/*!
 * Returns a Worldpay format error message with title and code
 */
- (NSError *)errorWithTitle:(NSString *)title
                       code:(NSInteger)code;
/*!
 *  Helper method for making requests
 *
 *  @param url The url of the request
 *  @param requestDictionary Request parameters
 *  @param method Request method (GET, POST,...)
 *  @param success Success block
 *  @param success Sailure block
 *  @param additionalHeaders additional headers as NSDictionary
 */

-(void)makeRequestWithURL:(NSString *)url
        requestDictionary:(NSDictionary *)requestDictionary
                   method:(NSString *)method
                  success:(requestUpdateTokenSuccess)success
                  failure:(requestTokenFailure)failure
        additionalHeaders:(NSDictionary *)additionalHeaders;


@end
