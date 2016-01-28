//
//  WorldpayApplePayTests.m
//  Worldpay
//
//  Created by Bill Panagiotopoulos on 1/22/15.
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Worldpay.h"

@interface WorldpayApplePayTests : XCTestCase

@end

static inline void hxRunInMainLoop(void(^block)(BOOL *done)) {
    __block BOOL done = NO;
    block(&done);
    while (!done) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
}

@implementation WorldpayApplePayTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[Worldpay sharedInstance] setClientKey:@"L_C_58d93fc9-e325-45fa-8b4d-ef0c632f7c13"];
    [[Worldpay sharedInstance] setReusable:NO];
    [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];
    [[Worldpay sharedInstance] setServiceKey:@"L_S_60d7f849-3ff0-43fa-944e-dfd860c757ab"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateToken {
    
    NSString *token = @"{\n  \"version\": \"EC_v1\",\n  \"data\": \"U9/ai91IpO/HnTSAKznLbj8vW0DNLZMBpKQ2etsjPqxeNPyB8g6vew0Ud5I2BKIUKG+Kk0FgMRrqVSbDxbU378I4ccqB2+TRHP8ztuhASNImHlPBhW0Bu/G5GR6j9qfhU4PPYNxuOawmuX1WDLERRwjoIDl3lUWLRsSbktYaTM+zmfAgALFeJbno86YrSUvdJ4raQf2bPtNYwDfIeqxPdgb7F4ryYIZFNbQafI8rpncN81Y93nTFzJhf3NKJo6MuvyUQYkKcIxcc+BRp/BtnT4vBTUG2KAoRt/5dRFBl+cPRdKGor1mWtZzVgMpnaNNSGtJTX8o4DpB0b/Zh6lITKJIfYUKGrh6rD7IvVyAzeKRVANls8RQO1KSJ+L6bLdNta57SGx3rTNaJ1NhZkGgTAl/+wrU+k+u+rdbLwFV+Kw==\",\n  \"signature\": \"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\",\n  \"header\": {\n    \"transactionId\": \"2bc0ff81627867c0838d25265c59793b60dc54b40783ada08e4cd2465bf78017\",\n    \"ephemeralPublicKey\": \"MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAELlKHyR+dknjYw7M4EgYpTgd4Guo2hFsPUIoMbepLSpLnEUip/v4NFCn5y34FvXnv2WWSogm3HyYyzx1a5GOOTA==\",\n    \"publicKeyHash\": \"YOxgq2wRygfpFVkd4q7Tl0G1oHs4S5Wt92zBkyvzkMY=\"\n  }\n}";

    
    NSData *paymentData = [token dataUsingEncoding:NSUTF8StringEncoding];
    
    hxRunInMainLoop(^(BOOL *done) {
    /*
        [[Worldpay sharedInstance] createTokenWithPaymentData:paymentData
                                                      success:^(int code, NSDictionary *responseDictionary) {
                                                          *done = YES;
                                                      } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                          NSLog(@"%@", responseDictionary);
                                                          XCTFail(@"should not call failure block");
                                                          *done = YES;
                                                      }];
     */
    });
    
}

@end
