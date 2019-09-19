//
//  Worldpay.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

@import AFNetworking;

#include <sys/sysctl.h>
#include <mach/machine.h>

#import "Worldpay.h"

@interface Worldpay() <UITextFieldDelegate>

@property (nonatomic, copy) requestUpdateTokenSuccess CVCModalSuccess;
@property (nonatomic, copy) requestTokenFailure CVCModalFailure;
@property (nonatomic, copy) preRequestAction CVCModalBeforeRequest;

@property (nonatomic, copy) NSString *CVCModalToken;
@property (nonatomic, copy) NSString *CVCModalTfCVC;

@property (nonatomic, strong) AFURLSessionManager *networkManager;

@end

static NSUInteger const kWorldpayTimeout = 65;

#define api_version @"v1"

#define api_url @"https://api.worldpay.com/v1/"


@implementation Worldpay

#pragma mark - Sigleton Method

+ (Worldpay *)sharedInstance {
    static Worldpay *getInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        getInstance = [[self alloc] init];
        getInstance.validationType = WorldpayValidationTypeAdvanced;
    });
    
    return getInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        AFURLSessionManager *networkManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        responseSerializer.readingOptions = NSJSONReadingMutableContainers;
        networkManager.responseSerializer = responseSerializer;
        _networkManager = networkManager;
    }
    
    return self;
}

- (void)dealloc {
    [self.networkManager invalidateSessionCancelingTasks:YES];
}

- (NSString *)APIStringURL {
    return api_url;
}

#pragma mark - Setters

- (void)setValidationType:(WorldpayValidationType)validationType {    
    if (![self validationTypeIsValid:validationType]) {
        _validationType = WorldpayValidationTypeAdvanced;
    }
    else {
        _validationType = validationType;
    }
}

#pragma mark - Token Methods

- (void)createTokenWithNameOnCard:(NSString *)holderName
                       cardNumber:(NSString *)cardNumber
                  expirationMonth:(NSString *)expirationMonth
                   expirationYear:(NSString *)expirationYear
                              CVC:(NSString *)CVC
                          success:(requestUpdateTokenSuccess)success
                          failure:(requestTokenFailure)failure {
    
    cardNumber = [self stripCardNumberWithCardNumber:cardNumber];
    expirationYear = [self convertYearIfNeededWithYear:expirationYear];
    
    NSArray *errors = [self validateCardDetailsWithHolderName:holderName
                                                   cardNumber:cardNumber
                                              expirationMonth:expirationMonth
                                               expirationYear:expirationYear
                                                          CVC:CVC];
    
    if (errors.count > 0) {
        failure(nil, errors);
        
        return;
    }
    
    NSMutableDictionary *paymentMethodDictionary = [[NSMutableDictionary alloc]init];
    
    NSInteger intExpirationYear = expirationYear.integerValue;
    paymentMethodDictionary[@"type"] = @"Card";
    paymentMethodDictionary[@"name"] = holderName;
    paymentMethodDictionary[@"expiryMonth"] = expirationMonth;
    paymentMethodDictionary[@"expiryYear"] = @(2000 + intExpirationYear);
    paymentMethodDictionary[@"cardNumber"] = cardNumber;
    paymentMethodDictionary[@"type"] = @"Card";
    if (CVC.length) {
        paymentMethodDictionary[@"cvc"] = CVC;
    }
    
    NSMutableDictionary *cardDetailsDictionary = [[NSMutableDictionary alloc] init];
    
    cardDetailsDictionary[@"reusable"] = @(self.reusable);
    cardDetailsDictionary[@"clientKey"] = self.clientKey;
    cardDetailsDictionary[@"paymentMethod"] = paymentMethodDictionary;
    
    [self makeRequestWithURL:[NSString stringWithFormat:@"%@tokens", [self APIStringURL]]
           requestDictionary:cardDetailsDictionary
                      method:@"POST"
                     success:success
                     failure:failure
           additionalHeaders:nil];
}

- (void)createAPMTokenWithAPMName:(NSString *)apmName
                      countryCode:(NSString *)countryCode
                        apmFields:(NSDictionary *)apmFields
              shopperLanguageCode:(NSString *)shopperLanguageCode
                          success:(requestUpdateTokenSuccess)success
                          failure:(requestTokenFailure)failure {
    
    
    NSArray *errors = [self validateAPMDetailsWithAPMName:apmName countryCode:countryCode];
    if (errors.count > 0) {
        failure(nil, errors);
        
        return;
    }
    
    NSMutableDictionary *paymentMethodDictionary = [[NSMutableDictionary alloc]init];
    paymentMethodDictionary[@"type"] = @"APM";
    paymentMethodDictionary[@"apmName"] = apmName;
    paymentMethodDictionary[@"shopperCountryCode"] = countryCode;
    paymentMethodDictionary[@"apmFields"] = apmFields;
    
    NSMutableDictionary *apmDetailsDictionary = [[NSMutableDictionary alloc] init];
    apmDetailsDictionary[@"reusable"] = @(self.reusable);
    apmDetailsDictionary[@"clientKey"] = self.clientKey;
    apmDetailsDictionary[@"shopperLanguageCode"] = shopperLanguageCode;
    apmDetailsDictionary[@"paymentMethod"] = paymentMethodDictionary;
    
    [self makeRequestWithURL:[NSString stringWithFormat:@"%@tokens", [self APIStringURL]]
           requestDictionary:apmDetailsDictionary
                      method:@"POST"
                     success:success
                     failure:failure
           additionalHeaders:nil];
    
}

- (void)reuseToken:(NSString *)token
           withCVC:(NSString *)CVC
           success:(requestUpdateTokenSuccess)success
           failure:(updateTokenFailure)failure {
    
    NSArray *errors = [self validateCardDetailsWithCVC:CVC token:token];
    
    if (errors.count > 0) {
        failure(nil, errors);
        
        return;
    }
    
    NSMutableDictionary *cardDetailsDictionary = [[NSMutableDictionary alloc] init];
    cardDetailsDictionary[@"cvc"] = CVC;
    cardDetailsDictionary[@"clientKey"] = self.clientKey;
    
    [self makeRequestWithURL:[NSString stringWithFormat:@"%@tokens/%@", [self APIStringURL], token]
           requestDictionary:cardDetailsDictionary
                      method:@"PUT"
                     success:success
                     failure:failure
           additionalHeaders:nil];
}


#pragma mark - CVC Modal View Methods

- (void)showCVCModalWithParentView:(UIView *)parentView
                             token:(NSString *)token
                           success:(requestUpdateTokenSuccess)success
                             error:(updateTokenFailure)failure {
    [self showCVCModalWithParentView:parentView
                               token:token
                             success:success
                       beforeRequest:nil
                               error:failure];
}

- (void)showCVCModalWithParentView:(UIView *)parentView
                             token:(NSString *)token
                           success:(requestUpdateTokenSuccess)success
                     beforeRequest:(preRequestAction)beforeRequest
                             error:(updateTokenFailure)failure {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"CVC"
                                                                             message:NSLocalizedString(@"Please enter your CVC", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    __weak typeof(alertController) weakAlertController = alertController;
    __weak typeof(self) weak = self;
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              weak.CVCModalTfCVC = [[alertController textFields][0] text];
                                                              [weak confirmCVCAction:weakAlertController];
                                                          }];
    [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    
    self.CVCModalSuccess = success;
    self.CVCModalFailure = failure;
    self.CVCModalToken = token;
    self.CVCModalBeforeRequest = beforeRequest;
    
    [self.topViewController presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)confirmCVCAction:(id)sender {
    __weak typeof(self) weak = self;
    if (self.CVCModalBeforeRequest) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.CVCModalBeforeRequest();
        });
    }
    
    [self reuseToken:self.CVCModalToken
             withCVC:self.CVCModalTfCVC
             success:^(NSInteger code, NSDictionary *responseDictionary) {
                 
                 weak.CVCModalToken = nil;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     weak.CVCModalSuccess(code, responseDictionary);
                 });
             } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                          message:[errors.firstObject localizedDescription]
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               weak.CVCModalFailure(responseDictionary, errors);
                                                                           });
                                                                       }];
                 [alertController addAction:confirmAction];
                 
                 [weak.topViewController presentViewController:alertController animated:YES completion:nil];
             }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = (textField.text).length + string.length - range.length;
    return (newLength > 4) ? NO : YES;
}

#pragma mark - Validation Methods

- (NSArray *)validateAPMDetailsWithAPMName:(NSString *)apmName
                               countryCode:(NSString *)countryCode {
    
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if (![self validateAPMNameWithName:apmName]) {
        [errors addObject:[self errorWithTitle:NSLocalizedString(@"APM Name is not valid", nil) code:1]];
    }
    
    if (![self validateCountryCodeWithCode:countryCode]) {
        [errors addObject:[self errorWithTitle:NSLocalizedString(@"Country Code is not valid", nil) code:2]];
    }
    
    return errors;
}

- (NSArray *)validateCardDetailsWithHolderName:(NSString *)holderName
                                    cardNumber:(NSString *)cardNumber
                               expirationMonth:(NSString *)expirationMonth
                                expirationYear:(NSString *)expirationYear
                                           CVC:(NSString *)CVC {
    
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    
    if (![self validateCardExpiryWithMonth:expirationMonth.intValue year:expirationYear.intValue]) {
        [errors addObject:[self errorWithTitle:NSLocalizedString(@"Card Expiry is not valid", nil) code:1]];
    }
    
    if ((self.validationType == WorldpayValidationTypeBasic && ![self validateCardNumberBasicWithCardNumber:cardNumber]) ||
        (self.validationType == WorldpayValidationTypeAdvanced && ![self validateCardNumberAdvancedWithCardNumber:cardNumber])) {
        
        [errors addObject:[self errorWithTitle:NSLocalizedString(@"Card Number is not valid", nil) code:2]];
    }
    
    if (![self validateCardHolderNameWithName:holderName]) {
        [errors addObject:[self errorWithTitle:NSLocalizedString(@"Name on card is not valid", nil) code:3]];
    }
    
    if (![self validateCardCVCWithNumber:CVC]) {
        [errors addObject:[self errorWithTitle:NSLocalizedString(@"Card Verification Code is not valid", nil) code:4]];
    }
    
    return errors;
}

- (NSArray *)validateCardDetailsWithCVC:(NSString *)CVC
                                  token:(NSString *)token {
    
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if (CVC.length) {
        if ([self validateCardCVCWithNumber:CVC] == NO) {
            NSError *error = [self errorWithTitle:NSLocalizedString(@"Card Verification Code is not valid", nil) code:4];
            [errors addObject:error];
        }
    }
    
    if (!token.length) {
        [errors addObject:[self errorWithTitle:NSLocalizedString(@"Token can not be blank", nil) code:400]];
    }
    
    return errors;
}

- (BOOL)validateCardNumberBasicWithCardNumber:(NSString *)cardNumber {
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    return cardNumber.length && [self stringIsNumeric:cardNumber];
}

- (BOOL)validateCardNumberAdvancedWithCardNumber:(NSString *)cardNumber {
    if (!cardNumber.length) {
        return NO;
    }
    
    NSRange   searchedRange = NSMakeRange(0, cardNumber.length);
    NSString *pattern = @"[^0-9-\\s]+";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:cardNumber options:0 range:searchedRange];
    if (matches.count > 0) {
        return NO;
    }
    
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (cardNumber.length < 12 || cardNumber.length > 19) {
        return NO;
    }
    
    cardNumber = [[cardNumber componentsSeparatedByCharactersInSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet] componentsJoinedByString:@""];
    int c = 0;
    int d = 0;
    BOOL e = NO;
    for (int i = (int)cardNumber.length-1; i >= 0; i--) {
        NSString *g = [cardNumber substringWithRange:NSMakeRange(i, 1)];
        d = g.intValue;
        e && (d = d * 2) > 9 && (d = d - 9);
        c = c + d;
        e = !e;
    }
    
    if (c % 10 == 0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)validateCardExpiryWithMonth:(NSInteger)intMonth year:(NSInteger)intYear {
    
    NSString *strYear = [NSString stringWithFormat:@"%@", @(intYear)];
    NSString *strMonth = [NSString stringWithFormat:@"%@", @(intMonth)];
    
    if (!strMonth.length || ![self stringIsNumeric:strMonth] || !strYear.length || ![self stringIsNumeric:strYear]) {
        return NO;
    }
    
    intYear = [self convertYearIfNeededWithYear:strYear].integerValue;
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    NSInteger month_current = components.month;
    NSInteger year_current = components.year % 100;
    
    if (intYear < 0 || intYear > 99 || intMonth < 1 || intMonth > 12) {
        return NO;
    }
    else {
        if (intYear == year_current) {
            if (intMonth >= month_current) {
                return YES;
            }
            else {
                return NO;
            }
        }
        else if (intYear > year_current) {
            return YES;
        }
        else{
            return NO;
        }
    }
}

- (BOOL)validateCardCVCWithNumber:(NSString *)cvc {
    if (!cvc.length) {
        return YES;
    }
    
    if ([self stringIsNumeric:cvc]) {
        return YES;
    }
    
    return NO;
    
}

- (BOOL)validateCardHolderNameWithName:(NSString *)holderName {
    if (!holderName.length) {
        return NO;
    }
    
    holderName = [holderName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSCharacterSet *permittedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-'"];
    permittedCharacterSet = permittedCharacterSet.invertedSet;
    NSRange r = [holderName rangeOfCharacterFromSet:permittedCharacterSet];
    
    return r.location == NSNotFound;
}

#pragma mark -
#pragma mark Helper Methods


- (void)makeRequestWithURL:(NSString *)url
         requestDictionary:(NSDictionary *)requestDictionary
                    method:(NSString *)method
                   success:(requestUpdateTokenSuccess)success
                   failure:(requestTokenFailure)failure
         additionalHeaders:(NSDictionary *)additionalHeaders {
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer requestWithMethod:method
                                                       URLString:url
                                                      parameters:requestDictionary
                                                           error:nil];
    request.timeoutInterval = kWorldpayTimeout;
    [request setValue:[self customHeader] forHTTPHeaderField:@"X-wp-client-user-agent"];
    for (NSString *key in additionalHeaders.allKeys) {
        [request setValue:additionalHeaders[key] forHTTPHeaderField:key];
    }
    
    NSURLSessionDataTask *dataTask = [self.networkManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error == nil) {
            success(((NSHTTPURLResponse *)response).statusCode, responseObject);
        }
        else {
            failure(responseObject, @[error]);
        }
    }];
    
    [dataTask resume];
}

- (BOOL)validationTypeIsValid:(WorldpayValidationType)validationType {
    return validationType < WorldpayValidationTypeCount;
}

- (BOOL)validateAPMNameWithName:(NSString *)apmName {
    return apmName.length > 0;
}

- (BOOL)validateCountryCodeWithCode:(NSString *)countryCode {
    return countryCode.length > 0;
}

- (NSString *)convertYearIfNeededWithYear:(NSString *)year {
    NSString *result = nil;
    if (year.length == 4) {
        result = [year substringWithRange:NSMakeRange(2, 2)];
    }
    else if (year.length == 2) {
        result = year;
    }
    
    return result;
}

- (NSError *)errorWithTitle:(NSString *)title
                       code:(NSInteger)code {
    return [NSError errorWithDomain:@"com.worldpay.error"
                                         code:code
                                     userInfo:@{NSLocalizedDescriptionKey:title}];
}

- (BOOL)stringIsNumeric:(NSString *)string {
    NSCharacterSet *notDigits = [NSCharacterSet decimalDigitCharacterSet].invertedSet;
    return [string rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}

+ (WorldpayCardType)cardType:(NSString *)cardNumber {

    NSArray *patterns = @[
                          @{
                              @"type": @(WorldpayCardType_electron),
                              @"pattern": @"^(4026|417500|4405|4508|4844|4913|4917)\\d+$"
                              },
                          @{
                              @"type": @(WorldpayCardType_maestro),
                              @"pattern": @"^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390|6799)\\d+$"
                              },
                          @{
                              @"type": @(WorldpayCardType_dankort),
                              @"pattern": @"^(5019)\\d+$"
                              },
                          @{
                              @"type": @(WorldpayCardType_interpayment),
                              @"pattern": @"^(636)\\d+$"
                              },
                          @{
                              @"type": @(WorldpayCardType_unionpay),
                              @"pattern": @"^(62|88)\\d+$"
                              },
                          @{
                              @"type": @(WorldpayCardType_visa),
                              @"pattern": @"^4[0-9]{12}(?:[0-9]{3})?$"
                              },
                          @{
                              @"type": @(WorldpayCardType_mastercard),
                              @"pattern": @"^5[1-5][0-9]{14}$"
                              },
                          @{
                              @"type": @(WorldpayCardType_amex),
                              @"pattern": @"^3[47][0-9]{13}$"
                              },
                          @{
                              @"type": @(WorldpayCardType_diners),
                              @"pattern": @"^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
                              },
                          @{
                              @"type": @(WorldpayCardType_discover),
                              @"pattern": @"^6(?:011|5[0-9]{2})[0-9]{12}$"
                              },
                          @{
                              @"type": @(WorldpayCardType_jcb),
                              @"pattern": @"^(?:2131|1800|35\\d{3})\\d{11}$"
                              },
                          @{
                              @"type": @(WorldpayCardType_laser),
                              @"pattern": @"^(6304|6706|6709|6771)[0-9]{12,15}$"
                              }
                          ];
    
    for (NSDictionary *pattern in patterns) {
        NSRange range = [cardNumber rangeOfString:pattern[@"pattern"] options:NSRegularExpressionSearch];
        
        if (range.location != NSNotFound) {
            return [pattern[@"type"] unsignedIntegerValue];
        }
    }
    
    return WorldpayCardType_unknown;
}

- (NSString *)customHeader {
    NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
    NSString *buildVersion = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    
    NSMutableString *value = [NSMutableString stringWithFormat:@"os.name=iOS;os.version=%@;os.arch=%@", [UIDevice currentDevice].systemVersion, [self cpuArchitecture]];
    
    if (buildVersion) {
        [value appendString:@";build.version="];
        [value appendString:buildVersion];
    }
    if (version) {
        [value appendString:@";lib.version="];
        [value appendString:version];
    }
    
    [value appendString:@";api.version="];
    [value appendString:api_version];
    [value appendString:@";lang=objective-c;owner=worldpay;"];
    
    return value;
}


- (NSString *)stripCardNumberWithCardNumber:(NSString *)cardNumber{
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    return cardNumber;
}

- (NSMutableString *)cpuArchitecture{
    NSMutableString *cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    
    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
    
    if (type == CPU_TYPE_X86)
    {
        [cpu appendString:@"x86"];
    }
    else if (type == CPU_TYPE_ARM64) {
        [cpu appendString:@"arm64"];
    }
    else if (type == CPU_TYPE_ARM)
    {
        [cpu appendString:@"arm"];
        switch (subtype)
        {
            case CPU_SUBTYPE_ARM_V6:
                [cpu appendString:@"v6"];
                break;
            case CPU_SUBTYPE_ARM_V7:
                [cpu appendString:@"v7"];
                break;
        }
    }
    
    return cpu;
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

@end
