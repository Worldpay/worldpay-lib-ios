//
//  ThreeDSController.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "ThreeDSController.h"
#import "Worldpay.h"
#import "AFNetworking.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CommonCrypto/CommonDigest.h>

#define TempURL "https://online.worldpay.com/3dsr/"

@interface ThreeDSController ()<UIWebViewDelegate>
@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, copy) NSString *currentOrderCode;
@property (nonatomic, copy) threeDSOrderSuccess authorizeSuccessBlock;
@property (nonatomic, copy) threeDSOrderFailure authorizeFailureBlock;
@property (nonatomic, copy) NSString *sessionID;

@property (nonatomic, strong) AFURLSessionManager *networkManager;

@end

@implementation ThreeDSController

- (instancetype)init {
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

- (void)createNavigationBar {
    if (_customToolbar) {
        [self.view addSubview:_customToolbar];
        return;
    }
    
    UIView *navigationBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    
    navigationBarView.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
    _customToolbar = navigationBarView;
    
    [self.view addSubview:navigationBarView];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, 80, 30)];
    [closeBtn setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    
    [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onTouchCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBarView addSubview:closeBtn];
    
    _sessionID = [self uniqueSessionID];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createNavigationBar];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 50.0,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - self.customToolbar.frame.size.height)];
    webView.delegate = self;
    [self.view addSubview:webView];
    _webView = webView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initializeThreeDS];
}

- (IBAction)onTouchCloseButton:(id)sender {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"User cancelled 3DS authorization", nil) code:0]];
    _authorizeFailureBlock(@{}, errors);
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - 3DS Methods

- (void)initializeThreeDS {
    NSString *stringURL = [[[Worldpay sharedInstance] APIStringURL] stringByAppendingPathComponent:@"orders"];
    
    NSDictionary *params = @{
                             @"token": _token,
                             @"orderType": @"RECURRING",
                             @"orderDescription": @"Goods and Services",
                             @"amount": @((float)(ceil(_price * 100))),
                             @"currencyCode": @"GBP",
                             @"settlementCurrency": @"GBP",
                             @"name": @"3D",
                             @"billingAddress": @{
                                     @"address1": _address,
                                     @"postalCode": _postalCode,
                                     @"city": _city,
                                     @"countryCode": @"GB"
                                     },
                             @"authorizeOnly" : @([Worldpay sharedInstance].authorizeOnly),
                             @"customerIdentifiers": (_customerIdentifiers && _customerIdentifiers.count > 0) ? _customerIdentifiers : @{},
                             @"is3DSOrder": @(YES),
                             @"shopperAcceptHeader": @"application/json",
                             @"shopperUserAgent": [self userAgent],
                             @"shopperSessionId": _sessionID,
                             @"shopperIpAddress": [self getIPAddress]
                             };
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST"
                                                       URLString:stringURL
                                                      parameters:params
                                                           error:nil];
    
    [request addValue:[Worldpay sharedInstance].serviceKey forHTTPHeaderField:@"Authorization"];
    __weak typeof(self) weak = self;
    NSURLSessionDataTask *dataTask = [self.networkManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([[responseObject objectForKey:@"paymentStatus"] isEqualToString:@"PRE_AUTHORIZED"]) {
            weak.currentOrderCode = [responseObject objectForKey:@"orderCode"];
            
            NSArray *params = @[
                                @{
                                    @"key": @"PaReq",
                                    @"value": [responseObject objectForKey:@"oneTime3DsToken"]
                                    },
                                @{
                                    @"key": @"TermUrl",
                                    @"value": @TempURL
                                    },
                                ];
            [weak redirectToThreeDSPageWithRedirectURL:[responseObject objectForKey:@"redirectURL"]
                                                params:params];
        }
        else {
            NSMutableArray *errors = [[NSMutableArray alloc] init];
            [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"There was an error creating the 3DS Order.", nil) code:1]];
            weak.authorizeFailureBlock(responseObject, errors);
        }
    }];
    
    [dataTask resume];
}

- (void)redirectToThreeDSPageWithRedirectURL:(NSString *)redirectURL
                                      params:(NSArray *)params {
    NSURL *url = [NSURL URLWithString:redirectURL];
    
    NSMutableArray *keyValueParams = [NSMutableArray array];
    for (NSDictionary *item in params) {
        [keyValueParams addObject:[NSString stringWithFormat:@"%@=%@", item[@"key"], [item[@"value"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]]];
    }
    
    NSString *body = [keyValueParams componentsJoinedByString:@"&"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding: NSUTF8StringEncoding];
    [_webView loadRequest: request];
}

- (void)authorize3DSOrder:(NSString *)orderCode
                    paRes:(NSString *)paRes {
    
    NSString *stringURL = [[[[Worldpay sharedInstance] APIStringURL] stringByAppendingPathComponent:@"orders"] stringByAppendingPathComponent:orderCode];
    
    NSDictionary *params = @{
                             @"threeDSResponseCode": paRes,
                             @"shopperAcceptHeader": @"application/json",
                             @"shopperUserAgent": [self userAgent],
                             @"shopperSessionId": _sessionID,
                             @"shopperIpAddress": [self getIPAddress]
                             };
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"PUT"
                                                       URLString:stringURL
                                                      parameters:params
                                                           error:nil];
    
    [request addValue:[Worldpay sharedInstance].serviceKey forHTTPHeaderField:@"Authorization"];
    __weak typeof(self) weak = self;
    NSURLSessionDataTask *dataTask = [self.networkManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSString *status = [responseObject objectForKey:@"paymentStatus"];
        if ([status isEqualToString:@"SUCCESS"] || [status isEqualToString:@"AUTHORIZED"]) {
            weak.authorizeSuccessBlock(responseObject);
        } else {
            NSMutableArray *errors = [[NSMutableArray alloc] init];
            [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"Error authorizing 3DS Order", nil) code:1]];
            weak.authorizeFailureBlock(responseObject, errors);
        }
    }];
    
    [dataTask resume];
}

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString containsString:@"worldpay-scheme://"]) {
        NSString *paRes = [self paramFromURL:request.URL.absoluteString key:@"PaRes"];
        [self authorize3DSOrder:_currentOrderCode paRes:paRes];
    }
    
    return YES;
}


- (void)setAuthorizeThreeDSOrderBlockWithSuccess:(threeDSOrderSuccess)success
                                         failure:(threeDSOrderFailure)failure {
    _authorizeSuccessBlock = success;
    _authorizeFailureBlock = failure;
}

#pragma mark - Helper Methods

- (NSArray *)paramsFromURLToDictionary:(NSString *)stringURL {
    NSString *getParams = [stringURL componentsSeparatedByString:@"?"][1];
    NSArray *paramComponents = [getParams componentsSeparatedByString:@"&"];
    NSMutableArray *params = [NSMutableArray array];
    
    for (NSString *param in paramComponents) {
        NSArray *parts = [param componentsSeparatedByString:@"="];
        
        [params addObject:@{
                            @"key": parts[0],
                            @"value": parts[1]
                            }];
    }
    
    return params;
}

- (NSString *)paramFromURL:(NSString *)stringURL
                       key:(NSString *)key {
    
    NSArray *params = [self paramsFromURLToDictionary:stringURL];
    NSArray *foundArray = [params filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key = %@", key]];
    
    if (foundArray.count > 0) {
        return foundArray[0][@"value"];
    }
    
    return nil;
}


// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([@(temp_addr->ifa_name) isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = @(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr));
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (NSString *)userAgent {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    return [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}

- (NSString *)MD5String:(NSString *)text {
    const char *cstr = text.UTF8String;
    unsigned char result[16];
    CC_MD5(cstr, (unsigned int)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)uniqueSessionID {
    NSString        *dateString;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd-MM-yyyy HH:mm";
    
    dateString = [formatter stringFromDate:[NSDate date]];
    return [self MD5String:dateString];
}


@end
