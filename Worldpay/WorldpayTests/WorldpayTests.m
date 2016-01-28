//
//  WorldpayTests.m
//  WorldpayTests
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Worldpay.h"

@interface WorldpayTests : XCTestCase

@end

@implementation WorldpayTests

static inline void hxRunInMainLoop(void(^block)(BOOL *done)) {
    __block BOOL done = NO;
    block(&done);
    while (!done) {
        [[NSRunLoop mainRunLoop] runUntilDate:
         [NSDate dateWithTimeIntervalSinceNow:.1]];
    }
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[Worldpay sharedInstance] setClientKey:@"T_C_8f883771-0207-43fe-bbd7-129cdfe36b08"];
    [[Worldpay sharedInstance] setServiceKey:@"T_S_d90baf09-3e35-410c-ab4c-0930cfa5436f"];

    [[Worldpay sharedInstance] setReusable:NO];
    [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValidationType {   
    //Test valid types
    [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeBasic];
    XCTAssertTrue([[Worldpay sharedInstance] validationType] == WorldpayValidationTypeBasic);
    
    [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];
    XCTAssertTrue([[Worldpay sharedInstance] validationType] == WorldpayValidationTypeAdvanced);
}

- (void)testCreateToken {
    /**
     *  Failure
     */
    hxRunInMainLoop(^(BOOL *done) {
        [[Worldpay sharedInstance] createTokenWithNameOnCard:@"^&*AghA GHAJdas" cardNumber:@"1cczz zvs safd  asd" expirationMonth:@"-1" expirationYear:@"21" CVC:@"---" success:^(int code, NSDictionary *responseDictionary) {
            
            XCTFail(@"should not call success block");
            
            *done = YES;
        } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
            
            XCTAssertTrue(errors.count == 4 && [[errors objectAtIndex:0] code] == 1 &&
                                               [[errors objectAtIndex:1] code] == 2 &&
                                               [[errors objectAtIndex:2] code] == 3 &&
                                               [[errors objectAtIndex:3] code] == 4, @"error codes should be 1,2,3,4");
            
            *done = YES;
        }];
    });
    
    /**
     *  Success
     */
    hxRunInMainLoop(^(BOOL *done) {
        [[Worldpay sharedInstance] createTokenWithNameOnCard:@"John Doe" cardNumber:@"6759649826438453" expirationMonth:@"05" expirationYear:@"21" CVC:@"067" success:^(int code, NSDictionary *responseDictionary) {
            
            *done = YES;
        } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
            
            XCTFail(@"should not call failure block");
            *done = YES;
        }];
    });
}

- (void)testCreateAPMToken {
    /**
     *  Failure
     */
    

    hxRunInMainLoop(^(BOOL *done) {
        [[Worldpay sharedInstance] createAPMTokenWithAPMName:@"" countryCode:@"" apmFields:nil shopperLanguageCode:nil success:^(int code, NSDictionary *responseDictionary) {
            
            XCTFail(@"should not call success block");
            *done = YES;
            
        } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
            
            XCTAssertTrue(errors.count == 2 && [[errors objectAtIndex:0] code] == 1 &&
                          [[errors objectAtIndex:1] code] == 2, @"error codes should be 1,2,3,4");
            
            *done = YES;
        }];
    });
    
    /**
     *  Success (paypal)
     */
    hxRunInMainLoop(^(BOOL *done) {
        [[Worldpay sharedInstance] createAPMTokenWithAPMName:@"paypal" countryCode:@"GB" apmFields:nil shopperLanguageCode:nil success:^(int code, NSDictionary *responseDictionary) {
            
            *done = YES;
        } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                    
            XCTFail(@"should not call failure block");
            *done = YES;
        }];
    });
    
    /**
     *  Success (Giropay)
     */
    hxRunInMainLoop(^(BOOL *done) {
        [[Worldpay sharedInstance] createAPMTokenWithAPMName:@"giropay" countryCode:@"GB" apmFields:@{
                                                                                                      @"swiftCode": @"ABC12345"
                                                                                                      } shopperLanguageCode:@"EN" success:^(int code, NSDictionary *responseDictionary) {
                                                                                                          
                                                                                                          //        [[Worldpay sharedInstance] createAPMTokenWithAPMName:@"paypal" countryCode:@"GB" apmFields:nil shopperLanguageCode:nil success:^(int code, NSDictionary *responseDictionary) {
                                                                                                          
                                                                                                          *done = YES;
                                                                                                      } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                                                                          
                                                                                                          XCTFail(@"should not call failure block");
                                                                                                          *done = YES;
                                                                                                      }];
    });
}

- (void)testReuseToken {
    /**
     *  Get the token
     */
    
    __block NSString *token = nil;
    
    hxRunInMainLoop(^(BOOL *done) {
        [[Worldpay sharedInstance] createTokenWithNameOnCard:@"John Doe"
                                                  cardNumber:@"6759649826438453"
                                             expirationMonth:@"05"
                                              expirationYear:@"21"
                                                         CVC:@"067"
                                                     success:^(int code, NSDictionary *responseDictionary) {
            
            token = [responseDictionary objectForKey:@"token"];
            
            *done = YES;
        } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
            
            XCTFail(@"should not call failure block");
            *done = YES;
        }];
    });
    
    /**
     *  Failure
     */
    hxRunInMainLoop(^(BOOL *done) {
        [[Worldpay sharedInstance] reuseToken:token withCVC:@"-14" success:^(int code, NSDictionary *responseDictionary) {
            XCTFail(@"should not call success block");
            *done = YES;
        } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
            XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 4, @"error should have code 4");
            *done = YES;
        }];
    });
    
    /**
     *  Success
     */
    hxRunInMainLoop(^(BOOL *done) {
        [[Worldpay sharedInstance] reuseToken:token withCVC:@"067" success:^(int code, NSDictionary *responseDictionary) {
            *done = YES;
        } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
            XCTFail(@"should not call failure block");
            *done = YES;
        }];
    });
}


- (void)testExpiryDate {
    /**
     *  Invalid Data
     */
    NSArray *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                                        cardNumber:@"6759649826438453"
                                                                   expirationMonth:@""
                                                                    expirationYear:@""
                                                                               CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 1, @"error should have code 1");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:nil
                                                           expirationYear:nil
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 1, @"error should have code 1");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"-1"
                                                           expirationYear:@"10"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 1, @"error should have code 1");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"-1"
                                                           expirationYear:@"10"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 1, @"error should have code 1");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"0"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 1, @"error should have code 1");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"fasj"
                                                           expirationYear:@"fasfafsdfdas"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 1, @"error should have code 1");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"--"
                                                           expirationYear:@"(" CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 1, @"error should have code 1");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"01"
                                                           expirationYear:@"14"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 1, @"error should have code 1");
    
    

    
    /**
     *  Valid Data
     */
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"01"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"02"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"03"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"12"
                                                           expirationYear:@"52"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Test Test"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"2"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
    

    
}

- (void)testExpiryDateSub {
    /**
     *  Invalid Data
     */
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardExpiryWithMonth:01 year:2014], @"return value should be NO");
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardExpiryWithMonth:01 year:14], @"return value should be NO");
    
    /**
     *  Valid Data
     */
    XCTAssertTrue([[Worldpay sharedInstance] validateCardExpiryWithMonth:12 year:2016], @"return value should be YES");
    XCTAssertTrue([[Worldpay sharedInstance] validateCardExpiryWithMonth:12 year:16], @"return value should be YES");
}

- (void)testHolderName {
    /**
     *  Invalid Data
     */
    NSArray *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@""
                                                                        cardNumber:@"6759649826438453"
                                                                   expirationMonth:@"05"
                                                                    expirationYear:@"21"
                                                                               CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 3, @"error should have code 3");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:nil
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 3, @"error should have code 3");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"vas1l14 p4n4g!0t0p0u1os"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 3, @"error should have code 3");
    
    /**
     *  Valid Data
     */
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be presented");

    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Steve Jobs"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be presented");
  
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"O'Connor"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
  
    XCTAssertTrue(errors.count == 0, @"no error should be presented");
  
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"Banks-Smith"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
  
    XCTAssertTrue(errors.count == 0, @"no error should be presented");
}

- (void)testHolderNameSub {
    /**
     *  Invalid Data
     */
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardHolderNameWithName:@"2"], @"return value should be NO");
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardHolderNameWithName:nil], @"return value should be NO");
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardHolderNameWithName:@"dsadsadsa-!@#"], @"return value should be NO");
    
    /**
     *  Valid Data
     */
    XCTAssertTrue([[Worldpay sharedInstance] validateCardHolderNameWithName:@"John Jobs"], @"return value should be YES");
    XCTAssertTrue([[Worldpay sharedInstance] validateCardHolderNameWithName:@"Stiv Tzops"], @"return value should be YES");
    XCTAssertTrue([[Worldpay sharedInstance] validateCardHolderNameWithName:@"Ahmed AHdnajnxahuy"], @"return value should be YES");
}

- (void)testCardNumber {
    
    [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeBasic];
    
    /**
     *  Invalid Data - Basic
     */
    
    NSArray *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                                        cardNumber:@"111122223333444-"
                                                                   expirationMonth:@"05"
                                                                    expirationYear:@"21"
                                                                               CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 2, @"error should have code 2");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                                        cardNumber:@"111122223333444-"
                                                                   expirationMonth:@"05"
                                                                    expirationYear:@"21"
                                                                               CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 2, @"error should have code 2");
    

    
    /**
     *  Valid Data - Basic
     */
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"1234123412341234"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be presented");
    
    [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];
    
    /**
     *  Invalid Data - Advanced
     */
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"1234123412341234"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 2, @"error code should be 2");
    
    /**
     *  Valid Data - Advanced
     */
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"067"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be presented");
}

- (void)testCardNumberSub {
    /**
     *  Invalid Data
     */
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardNumberBasicWithCardNumber:@""], @"return value should be NO");
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardNumberBasicWithCardNumber:nil], @"return value should be NO");
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardNumberAdvancedWithCardNumber:@""], @"return value should be NO");
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardNumberAdvancedWithCardNumber:nil], @"return value should be NO");
    
    /**
     *  Valid Data
     */
    XCTAssertTrue([[Worldpay sharedInstance] validateCardNumberBasicWithCardNumber:@"6759649826438453"], @"return value should be YES");
    XCTAssertTrue([[Worldpay sharedInstance] validateCardNumberAdvancedWithCardNumber:@"4444333322221111"], @"return value should be YES");
}



- (void)testCardAndCVC {
    /**
     *  Invalid Data
     */
    [[Worldpay sharedInstance] validateCardDetailsWithCVC:@"!32" token:@""];
    [[Worldpay sharedInstance] validateCardDetailsWithCVC:@"!df2" token:nil];
    
    [[Worldpay sharedInstance] validateCardDetailsWithCVC:@"" token:@"TEST_SU_e957a368-78ce-421b-9348-4cfca91c1cdb"];
    [[Worldpay sharedInstance] validateCardDetailsWithCVC:nil token:@"TEST_SU_e957a368-78ce-421b-9348-4cfca91c1cdb"];
}

- (void)testCVC {
    
    /**
     *  Invalid Data
     */
    
    
    NSArray *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"!1#@"];
    
    XCTAssertTrue(errors.count == 1 && [[errors objectAtIndex:0] code] == 4, @"error should have code 4");

    
    /**
     *  Valid Data
     */
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                                        cardNumber:@"6759649826438453"
                                                                   expirationMonth:@"05"
                                                                    expirationYear:@"21"
                                                                               CVC:nil];
    
    XCTAssertTrue(errors.count == 0, @"no errors should be presented");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@""];
    
    XCTAssertTrue(errors.count == 0, @"no errors should be presented");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"312"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"111"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"4412"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
    
    errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"John Doe"
                                                               cardNumber:@"6759649826438453"
                                                          expirationMonth:@"05"
                                                           expirationYear:@"21"
                                                                      CVC:@"0015"];
    
    XCTAssertTrue(errors.count == 0, @"no error should be returned");
}

- (void)testCVCSub {
    /**
     *  Invalid Data
     */
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardCVCWithNumber:@"@!#%!"], @"should return NO");
    XCTAssertTrue(![[Worldpay sharedInstance] validateCardCVCWithNumber:@"hello"], @"should return NO");
    
    /**
     *  Valid Data
     */
    XCTAssertTrue([[Worldpay sharedInstance] validateCardCVCWithNumber:@""], @"should return YES");
    XCTAssertTrue([[Worldpay sharedInstance] validateCardCVCWithNumber:nil], @"should return YES");
    XCTAssertTrue([[Worldpay sharedInstance] validateCardCVCWithNumber:@"22233"], @"should return YES");
}

- (void)testCardType {
    
    /**
     *  American Express
     */
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"378282246310005"] isEqualToString:@"amex"], @"Card type is amex");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"371449635398431"] isEqualToString:@"amex"], @"Card type is amex");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"378734493671000"] isEqualToString:@"amex"], @"Card type is amex");
    
    /**
     *  MasterCard
     */
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"5555555555554444"] isEqualToString:@"mastercard"], @"Card type is MasterCard");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"5105105105105100"] isEqualToString:@"mastercard"], @"Card type is MasterCard");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"5454545454545454"] isEqualToString:@"mastercard"], @"Card type is MasterCard");
    
    /**
     *  Visa
     */
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"4111111111111111"] isEqualToString:@"visa"], @"Card type is Visa");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"4012888888881881"] isEqualToString:@"visa"], @"Card type is Visa");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"4222222222222"] isEqualToString:@"visa"], @"Card type is Visa");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"4462030000000000"] isEqualToString:@"visa"], @"Card type is Visa");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"4444333322221111"] isEqualToString:@"visa"], @"Card type is Visa");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"4911830000000"] isEqualToString:@"visa"], @"Card type is Visa");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"4462030000000000"] isEqualToString:@"visa"], @"Card type is Visa");
    
    /**
     *  Maestro
     */
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"6759649826438453"] isEqualToString:@"maestro"], @"Card type is Maestro");
    XCTAssertTrue([[[Worldpay sharedInstance] cardType:@"6799990100000000019"] isEqualToString:@"maestro"], @"Card type is Maestro");
    
}

@end
