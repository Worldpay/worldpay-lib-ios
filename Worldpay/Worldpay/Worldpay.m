//
//  Worldpay.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "Worldpay.h"
#import "WorldpayUtils.h"
#import <AFNetworking/AFNetworking.h>

@interface Worldpay()<UITextFieldDelegate>
    @property (nonatomic, copy) requestUpdateTokenSuccess CVCModalSuccess;
    @property (nonatomic, copy) requestTokenFailure CVCModalFailure;
    @property (nonatomic, copy) void (^CVCModalBeforeRequest)(void);
    @property (nonatomic, retain) NSString *CVCModalToken;
    @property (nonatomic, retain) UIView *CVCModalBackgroundView;
    @property (nonatomic, retain) NSString *CVCModalTfCVC;
    @property (nonatomic, retain) UIActivityIndicatorView *CVCModalActivityIndicatorView;
    @property (nonatomic, retain) UIButton *CVCModalBtnConfirm;
@end

@implementation Worldpay

#pragma mark - Sigleton Method

+ (Worldpay *)sharedInstance {
    static Worldpay *getInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        getInstance = [[self alloc] init];
        [getInstance setValidationType:WorldpayValidationTypeAdvanced];
        
        [WorldpayUtils loadFont:@"ArialMT"];
    });
    return getInstance;
}

- (id)init{
    if (self = [super init]) {
        WorldpayTimeout = 65;
    }
    return self;
}

- (NSString *)APIStringURL {
    return api_url;
}

#pragma mark - Setters

- (void)setValidationType:(WorldpayValidationType)validationType {    
    if (![self validationTypeIsValid:validationType]) {
        _validationType = WorldpayValidationTypeAdvanced;
    } else {
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
    
    NSMutableDictionary *cardDetailsDictionary = [[NSMutableDictionary alloc] init];
    
    [cardDetailsDictionary setValue:[NSNumber numberWithBool:self.reusable] forKey:@"reusable"];
    [cardDetailsDictionary setValue:_clientKey forKey:@"clientKey"];
    
    NSMutableDictionary *paymentMethodDictionary = [[NSMutableDictionary alloc]init];
    
    NSInteger intExpirationYear = [expirationYear integerValue];
    
    [paymentMethodDictionary setValue:@"Card" forKey:@"type"];
    [paymentMethodDictionary setValue:holderName forKey:@"name"];
    [paymentMethodDictionary setValue:expirationMonth forKey:@"expiryMonth"];
    [paymentMethodDictionary setValue:[NSNumber numberWithInteger:intExpirationYear+2000] forKey:@"expiryYear"];
    [paymentMethodDictionary setValue:cardNumber forKey:@"cardNumber"];
    if(CVC !=nil){
        [paymentMethodDictionary setValue:CVC forKey:@"cvc"];
    }
    
    [cardDetailsDictionary setValue:paymentMethodDictionary forKey:@"paymentMethod"];
    
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
    
    NSMutableDictionary *apmDetailsDictionary = [[NSMutableDictionary alloc] init];
    
    [apmDetailsDictionary setValue:[NSNumber numberWithBool:self.reusable] forKey:@"reusable"];
    [apmDetailsDictionary setValue:_clientKey forKey:@"clientKey"];
    [apmDetailsDictionary setValue:shopperLanguageCode forKey:@"shopperLanguageCode"];

    NSMutableDictionary *paymentMethodDictionary = [[NSMutableDictionary alloc]init];
    
    [paymentMethodDictionary setValue:@"APM" forKey:@"type"];
    [paymentMethodDictionary setValue:apmName forKey:@"apmName"];
    [paymentMethodDictionary setValue:countryCode forKey:@"shopperCountryCode"];
    [paymentMethodDictionary setValue:apmFields forKey:@"apmFields"];
    
    [apmDetailsDictionary setValue:paymentMethodDictionary forKey:@"paymentMethod"];
    
    [self makeRequestWithURL:[NSString stringWithFormat:@"%@tokens", [self APIStringURL]]
           requestDictionary:apmDetailsDictionary
                      method:@"POST"
                     success:success
                     failure:failure
           additionalHeaders:nil];
    
}

-(void)reuseToken:(NSString *)token
          withCVC:(NSString *)CVC
          success:(requestUpdateTokenSuccess)success
          failure:(updateTokenFailure)failure {
    
    NSArray *errors = [self validateCardDetailsWithCVC:CVC token:token];
    
    if (errors.count > 0) {
        failure(nil, errors);
        return;
    }
    
    NSMutableDictionary *cardDetailsDictionary = [[NSMutableDictionary alloc] init];
    
    [cardDetailsDictionary setValue:CVC forKey:@"cvc"];
    [cardDetailsDictionary setValue:_clientKey forKey:@"clientKey"];
    
    [self makeRequestWithURL:[NSString stringWithFormat:@"%@tokens/%@", [self APIStringURL], token]
           requestDictionary:cardDetailsDictionary
                      method:@"PUT"
                     success:success
                     failure:failure
           additionalHeaders:nil];
}


#pragma mark - CVC Modal View Methods


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.CVCModalTfCVC = [[alertView textFieldAtIndex:0] text];
    [self confirmCVCAction:alertView];
}

-(void)showCVCModalWithParentView:(UIView *)parentView
                            token:(NSString *)token
                          success:(requestUpdateTokenSuccess)success
                            error:(updateTokenFailure)failure {
    [self showCVCModalWithParentView:parentView
                               token:token
                             success:success
                       beforeRequest:nil
                               error:failure];
}

-(void)showCVCModalWithParentView:(UIView *)parentView
                            token:(NSString *)token
                          success:(requestUpdateTokenSuccess)success
                    beforeRequest:(void (^)(void))beforeRequest
                            error:(updateTokenFailure)failure {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"CVC" message:NSLocalizedString(@"Please enter your CVC", nil) delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    
    self.CVCModalSuccess = success;
    self.CVCModalFailure = failure;
    self.CVCModalToken = token;
    self.CVCModalBeforeRequest = beforeRequest;
    [alert show];
}


- (IBAction)confirmCVCAction:(id)sender {
    self.CVCModalBtnConfirm.enabled = NO;
    [self.CVCModalActivityIndicatorView startAnimating];
    if (self.CVCModalBeforeRequest) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.CVCModalBeforeRequest();
        });
    }
    [self reuseToken:self.CVCModalToken
             withCVC:self.CVCModalTfCVC
             success:^(int code, NSDictionary *responseDictionary) {
                 
                 self.CVCModalToken = nil;
                 self.CVCModalBtnConfirm.enabled = YES;
                 [self.CVCModalActivityIndicatorView stopAnimating];
                 dispatch_async(dispatch_get_main_queue(), ^{
                    self.CVCModalSuccess(code, responseDictionary);
                 });
             } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                 self.CVCModalBtnConfirm.enabled = YES;
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                 message:[[errors objectAtIndex:0] localizedDescription]
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                 [alert show];
                 [self.CVCModalActivityIndicatorView stopAnimating];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.CVCModalFailure(responseDictionary, errors);
                 });
             }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;
}

#pragma mark - Validation Methods

-(NSArray *)validateAPMDetailsWithAPMName:(NSString *)apmName
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

-(NSArray *)validateCardDetailsWithHolderName:(NSString *)holderName
                                   cardNumber:(NSString *)cardNumber
                              expirationMonth:(NSString *)expirationMonth
                               expirationYear:(NSString *)expirationYear
                                          CVC:(NSString *)CVC {

    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    
    if (![self validateCardExpiryWithMonth:[expirationMonth intValue] year:[expirationYear intValue]]) {
        [errors addObject:[self errorWithTitle:NSLocalizedString(@"Card Expiry is not valid", nil) code:1]];
    }
    if ( (_validationType == WorldpayValidationTypeBasic && ![self validateCardNumberBasicWithCardNumber:cardNumber]) ||
         (_validationType == WorldpayValidationTypeAdvanced && ![self validateCardNumberAdvancedWithCardNumber:cardNumber]) ) {
        
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


-(NSArray *)validateCardDetailsWithCVC:(NSString *)CVC
                                 token:(NSString *)token {
    
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if(CVC != nil){
        if([self validateCardCVCWithNumber:CVC] == NO){
            
            NSError *error = [self errorWithTitle:NSLocalizedString(@"Card Verification Code is not valid", nil) code:4];
            [errors addObject:error];
        }
    }

    if([token isEqualToString:@""] || token == nil){
        [errors addObject:[self errorWithTitle:NSLocalizedString(@"Token can not be blank", nil) code:400]];
    }
    
    return errors;
}

-(BOOL)validateCardNumberBasicWithCardNumber:(NSString *)cardNumber{
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [self stringIsNumeric:cardNumber] && cardNumber && ![cardNumber isEqualToString:@""];
}

-(BOOL)validateCardNumberAdvancedWithCardNumber:(NSString *)cardNumber{
    if(cardNumber == nil || [cardNumber isEqualToString:@""]){
        return NO;
    }
    
    NSRange   searchedRange = NSMakeRange(0, [cardNumber length]);
    NSString *pattern = @"[^0-9-\\s]+";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSArray *matches = [regex matchesInString:cardNumber options:0 range:searchedRange];
    if([matches count] > 0){
        return NO;
    }
    
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    if([cardNumber length] < 12 || [cardNumber length] > 19){
        return NO;
    }
    cardNumber = [[cardNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    int c = 0;
    int d = 0;
    BOOL e = NO;
    for(int i = (int)[cardNumber length]-1; i>=0; i--){
        NSString *g = [cardNumber substringWithRange:NSMakeRange(i, 1)];
        d = [g intValue];
        e && (d = d * 2) > 9 && (d = d - 9);
        c = c + d;
        e = !e;
    }
    if(c % 10 == 0){
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)validateCardExpiryWithMonth:(int)intMonth year:(int)intYear {
    
    NSString *strYear = [NSString stringWithFormat:@"%i", intYear];
    NSString *strMonth = [NSString stringWithFormat:@"%i", intMonth];
    
    if (!strMonth || [strMonth isEqualToString:@""] || ![self stringIsNumeric:strMonth] || !strYear || [strYear isEqualToString:@""] || ![self stringIsNumeric:strYear]) {
        return NO;
    }
    
    intYear = [[self convertYearIfNeededWithYear:strYear] intValue];

    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    NSInteger month_current = [components month];
    NSInteger year_current = [components year] % 100;
    
    if(intYear < 0 || intYear > 99 || intMonth < 1 || intMonth > 12){
        return NO;
    }else{
        if(intYear == year_current){
            if(intMonth >= month_current){
                return YES;
            }else {
                return NO;
            }
        }else if(intYear > year_current){
            return YES;
        }else{
            return NO;
        }
    }
}

-(BOOL)validateCardCVCWithNumber:(NSString *)cvc{
    if (cvc == nil || [cvc isEqualToString:@""]) {
        return YES;
    }

    if([self stringIsNumeric:cvc]){
        return YES;
    }

    return NO;

}

- (BOOL)validateCardHolderNameWithName:(NSString *)holderName {
    if (!holderName || [holderName isEqualToString:@""]) {
        return NO;
    }
    
    holderName = [holderName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSCharacterSet *permittedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-'"];
    permittedCharacterSet = [permittedCharacterSet invertedSet];
    NSRange r = [holderName rangeOfCharacterFromSet:permittedCharacterSet];
    
    return r.location == NSNotFound;
}

#pragma mark -
#pragma mark Helper Methods


-(void)makeRequestWithURL:(NSString *)url
        requestDictionary:(NSDictionary *)requestDictionary
                   method:(NSString *)method
                  success:(requestUpdateTokenSuccess)success
                  failure:(requestTokenFailure)failure
        additionalHeaders:(NSDictionary *)additionalHeaders {

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:kNilOptions error:nil];
  
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:WorldpayTimeout];
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:[self customHeader] forHTTPHeaderField:@"X-wp-client-user-agent"];
  
    for (NSString *key in additionalHeaders.allKeys) {
      [request setValue:[additionalHeaders objectForKey:key] forHTTPHeaderField:key];
    }
  
    [request setHTTPBody:jsonData];
  
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success((int)operation.response.statusCode, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation.responseObject, @[error]);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
    
}

- (BOOL)validationTypeIsValid:(WorldpayValidationType)validationType {
    return validationType < validation_types;
}

-(BOOL)validateAPMNameWithName:(NSString *)apmName {
    if(apmName == nil || [apmName isEqualToString:@""]){
        return NO;
    }
    return YES;
}

-(BOOL)validateCountryCodeWithCode:(NSString *)countryCode {
    if(countryCode == nil || [countryCode isEqualToString:@""]){
        return NO;
    }
    return YES;
}

- (NSString *)convertYearIfNeededWithYear:(NSString *)year {
    if (year.length == 4) {
        return [year substringWithRange:NSMakeRange(2, 2)];
    }
    else if (year.length == 2) {
        return year;
    }
    
    return nil;
}

- (NSError *)errorWithTitle:(NSString *)title
                       code:(NSInteger)code {
    NSError *error = [NSError errorWithDomain:@"com.worldpay.error"
                                         code:code
                                     userInfo:@{NSLocalizedDescriptionKey:title}];
    return error;
}

- (BOOL)stringIsNumeric:(NSString *)string {
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [string rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}

- (NSString *)cardType:(NSString *)cardNumber {
    
    NSArray *patterns = @[
                          @{
                              @"type": @"electron",
                              @"pattern": @"^(4026|417500|4405|4508|4844|4913|4917)\\d+$"
                            },
                          @{
                              @"type": @"maestro",
                              @"pattern": @"^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390|6799)\\d+$"
                            },
                          @{
                              @"type": @"dankort",
                              @"pattern": @"^(5019)\\d+$"
                            },
                          @{
                              @"type": @"interpayment",
                              @"pattern": @"^(636)\\d+$"
                            },
                          @{
                              @"type": @"unionpay",
                              @"pattern": @"^(62|88)\\d+$"
                            },
                          @{
                              @"type": @"visa",
                              @"pattern": @"^4[0-9]{12}(?:[0-9]{3})?$"
                            },
                          @{
                              @"type": @"mastercard",
                              @"pattern": @"^5[1-5][0-9]{14}$"
                            },
                          @{
                              @"type": @"amex",
                              @"pattern": @"^3[47][0-9]{13}$"
                            },
                          @{
                              @"type": @"diners",
                              @"pattern": @"^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
                            },
                          @{
                              @"type": @"discover",
                              @"pattern": @"^6(?:011|5[0-9]{2})[0-9]{12}$"
                            },
                          @{
                              @"type": @"jcb",
                              @"pattern": @"^(?:2131|1800|35\\d{3})\\d{11}$"
                            }
                        ];
    
    for (NSDictionary *pattern in patterns) {
        NSRange range = [cardNumber rangeOfString:[pattern objectForKey:@"pattern"] options:NSRegularExpressionSearch];
        
        if (range.location != NSNotFound) {
            return [pattern objectForKey:@"type"];
        }
    }
    
    return @"unknown";
}

-(NSString *)customHeader{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *buildVersion = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSMutableString *value = [NSMutableString stringWithFormat:@"os.name=iOS;os.version=%@;os.arch=%@", [[UIDevice currentDevice] systemVersion], [self cpuArchitecture]];
    
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


-(NSString *)stripCardNumberWithCardNumber:(NSString *)cardNumber{
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    return cardNumber;
}

-(NSMutableString *)cpuArchitecture{
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
        switch(subtype)
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

@end
