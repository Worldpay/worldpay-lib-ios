//
//  WorldPay+ApplePay.h
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

@import Foundation;
@import PassKit;

#import "Worldpay.h"

@interface Worldpay (ApplePay)

/*!
 *  Method that indicates if the device supports ApplePay.]
 *
 *  @return bool if ApplePay is supported.
 */
@property (nonatomic, readonly) BOOL canMakePayments;

/*!
 *  Creates a new PKPaymentRequest object for the given Marchant Identifier.
 *  Merchant Identifiers can be created via Apple Developers Portal
 *
 *  @param marchantIdentifier the Merchant Identifier given as NSString
 *
 *  @return a new PKPaymentRequest
 */
- (PKPaymentRequest *)createPaymentRequestWithMerchantIdentifier:(NSString *)marchantIdentifier;

/*!
 *  Creates a new Worldpay token using an ApplePay token
 *
 *  @param payment the paymentData of PKPaymentToken object which contains an encrypted payment credential
 *  @param success success block returning (NSInteger code, NSDictionary *responseDictionary)
 *  @param failure failure block returning (NSDictionary *responseDictionary, NSArray *errors)
 *
 */

- (void)createTokenWithPayment:(PKPayment *)payment
                       success:(requestUpdateTokenSuccess)success
                       failure:(requestTokenFailure)failure;

/*!
 *  Creates a new Worldpay token using an ApplePay token data
 *
 *  @param paymentData the paymentData of PKPaymentToken object which contains an encrypted payment credential
 *  @param success success block returning (NSInteger code, NSDictionary *responseDictionary)
 *  @param failure failure block returning (NSDictionary *responseDictionary, NSArray *errors)
 *
 */
- (void)createTokenWithPaymentData:(NSData *)paymentData
                           success:(requestUpdateTokenSuccess)success
                           failure:(requestTokenFailure)failure;



@end
