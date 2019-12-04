//
//  WorldPay+ApplePay.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

@import AddressBook;

#import "Worldpay+ApplePay.h"

#define WorldpaySupportedNetworks @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]

@implementation Worldpay (ApplePay)

- (BOOL)canMakePayments {
    return [PKPaymentAuthorizationViewController canMakePayments]
        && [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:WorldpaySupportedNetworks];
}

- (PKPaymentRequest *)createPaymentRequestWithMerchantIdentifier:(NSString *)marchantIdentifier {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    
    paymentRequest.merchantIdentifier = marchantIdentifier;
    paymentRequest.supportedNetworks = WorldpaySupportedNetworks;
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.requiredBillingAddressFields = PKAddressFieldPostalAddress;
    
    return paymentRequest;
}

- (void)createTokenWithPayment:(PKPayment *)payment
                       success:(requestUpdateTokenSuccess)success
                       failure:(requestTokenFailure)failure {
    
    [self createTokenWithPaymentData:payment.token.paymentData
                             success:success
                             failure:failure];
}

- (void)createTokenWithPaymentData:(NSData *)paymentData
                           success:(requestUpdateTokenSuccess)success
                           failure:(requestTokenFailure)failure {
    
    
    NSString *tokenString = [[NSString alloc] initWithData:paymentData
                                                  encoding:NSUTF8StringEncoding];
    
    
    NSDictionary *params = @{
                             @"paymentMethod": @{
                                     @"type": @"ApplePay",
                                     @"applePayToken": tokenString,
                                     },
                             @"clientKey": self.clientKey,
                             @"reusable": @(self.reusable)
                             };
    
    [self makeRequestWithURL:[NSString stringWithFormat:@"%@/tokens", [[Worldpay sharedInstance] APIStringURL]]
           requestDictionary:params
                      method:@"POST"
                     success:success
                     failure:failure
           additionalHeaders:nil];
}

@end
