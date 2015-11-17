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
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *currentOrderCode;
@property (nonatomic,copy) threeDSOrderSuccess authorizeSuccessBlock;
@property (nonatomic,copy) threeDSOrderFailure authorizeFailureBlock;
@property (nonatomic, retain) NSString *sessionID;
@end

@implementation ThreeDSController

-(void)createNavigationBar{
    if (_customToolbar) {
        [self.view addSubview:_customToolbar];
        return;
    }
    
    UIView *navigationBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 50)];

    navigationBarView.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
    _customToolbar = navigationBarView;

    [self.view addSubview:navigationBarView];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, 80, 30)];
    [closeBtn setTitleColor:self.view.tintColor forState:UIControlStateNormal];

    [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBarView addSubview:closeBtn];
    
    _sessionID = [self uniqueSessionID];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createNavigationBar];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,50.0,self.view.frame.size.width,self.view.frame.size.height-self.customToolbar.frame.size.height)];
    _webView.delegate = self;
    
    [self.view addSubview:_webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self initializeThreeDS];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    if (self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - 3DS Methods

- (void)initializeThreeDS {
    NSString *stringURL = [[[Worldpay sharedInstance] APIStringURL] stringByAppendingPathComponent:@"orders"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:[[Worldpay sharedInstance] serviceKey] forHTTPHeaderField:@"Authorization"];

    NSDictionary *params = @{
                             @"token": _token,
                             @"orderType": @"ECOM",
                             @"orderDescription": @"Goods and Services",
                             @"amount": @((NSInteger)(_price * 100)),
                             @"currencyCode": @"GBP",
                             @"name": @"3D",
                             @"billingAddress": @{
                                     @"address1": _address,
                                     @"postalCode": _postalCode,
                                     @"city": _city,
                                     @"countryCode": @"GB"
                                     },
                             @"customerIdentifiers": @{
                                     @"email": @"john.smith@gmail.com"
                                     },
                             @"is3DSOrder": @(YES),
                             @"shopperAcceptHeader": @"application/json",
                             @"shopperUserAgent": [self userAgent],
                             @"shopperSessionId": _sessionID,
                             @"shopperIpAddress": [self getIPAddress]
                             };
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:0
                                                         error:&error];
    
    [request setHTTPBody:jsonData];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[responseObject objectForKey:@"paymentStatus"] isEqualToString:@"PRE_AUTHORIZED"]) {
            _currentOrderCode = [responseObject objectForKey:@"orderCode"];
            
            NSArray *params = @[
                                @{
                                    @"key": @"PaReq",
                                    @"value": [operation.responseObject objectForKey:@"oneTime3DsToken"]
                                    },
                                @{
                                    @"key": @"TermUrl",
                                    @"value": @TempURL
                                    },
                                ];
            [self redirectToThreeDSPageWithRedirectURL:[responseObject objectForKey:@"redirectURL"]
                                                params:params];
        }
        else if ([[responseObject objectForKey:@"paymentStatus"] isEqualToString:@"SUCCESS"]) {
            _authorizeSuccessBlock(responseObject);
        }
        else {
            NSMutableArray *errors = [[NSMutableArray alloc] init];
            [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"There was an error creating the 3DS Order.", nil) code:1]];
            _authorizeFailureBlock(responseObject, errors);
        }
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSMutableArray *errors = [[NSMutableArray alloc] init];
        [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"There was an error creating the 3DS Order.", nil) code:1]];
        _authorizeFailureBlock(operation.responseObject, errors);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];

}

- (void)redirectToThreeDSPageWithRedirectURL:(NSString *)redirectURL
                                      params:(NSArray *)params {

    
    NSURL *url = [NSURL URLWithString:redirectURL];
    
    NSMutableArray *keyValueParams = [NSMutableArray array];
    for (NSDictionary *item in params) {
        [keyValueParams addObject:[NSString stringWithFormat:@"%@=%@", [item objectForKey:@"key"], [[item objectForKey:@"value"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]]];
    }
    
    NSString *body = [keyValueParams componentsJoinedByString:@"&"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [_webView loadRequest: request];
}

- (void)authorize3DSOrder:(NSString *)orderCode
                                 paRes:(NSString *)paRes {
    
    NSString *stringURL = [[[[Worldpay sharedInstance] APIStringURL] stringByAppendingPathComponent:@"orders"] stringByAppendingPathComponent:orderCode];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"PUT"];
    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:[[Worldpay sharedInstance] serviceKey] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *params = @{
                                 @"threeDSResponseCode": paRes,
                                 @"shopperAcceptHeader": @"application/json",
                                 @"shopperUserAgent": [self userAgent],
                                 @"shopperSessionId": _sessionID,
                                 @"shopperIpAddress": [self getIPAddress]
                             };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:0
                                                         error:&error];
    
    [request setHTTPBody:jsonData];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *status = [operation.responseObject objectForKey:@"paymentStatus"];
        if ([status isEqualToString:@"SUCCESS"]) {
            _authorizeSuccessBlock(responseObject);
        } else {
            NSMutableArray *errors = [[NSMutableArray alloc] init];
            [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"Error authorizing 3DS Order", nil) code:1]];
            _authorizeFailureBlock(responseObject, errors);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSMutableArray *errors = [[NSMutableArray alloc] init];
        [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"Error authorizing 3DS Order", nil) code:1]];
        _authorizeFailureBlock(operation.responseObject, errors);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
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
    NSString *getParams = [[stringURL componentsSeparatedByString:@"?"] objectAtIndex:1];
    NSArray *paramComponents = [getParams componentsSeparatedByString:@"&"];
    NSMutableArray *params = [NSMutableArray array];
    
    for (NSString *param in paramComponents) {
        NSArray *parts = [param componentsSeparatedByString:@"="];
        
        [params addObject:@{
                            @"key": [parts objectAtIndex:0],
                            @"value": [parts objectAtIndex:1]
                            }];
    }

    return params;
}

- (NSString *)paramFromURL:(NSString *)stringURL
                       key:(NSString *)key {
    
    NSArray *params = [self paramsFromURLToDictionary:stringURL];
    NSArray *foundArray = [params filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key = %@", key]];
    
    if (foundArray.count > 0) {
        return [[foundArray objectAtIndex:0] objectForKey:@"value"];
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
    while(temp_addr != NULL) {
      if(temp_addr->ifa_addr->sa_family == AF_INET) {
        // Check if interface is en0 which is the wifi connection on the iPhone
        if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
          // Get NSString from C String
          address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
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
  UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
  return [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}

- (NSString *)MD5String:(NSString *)text {
  const char *cstr = [text UTF8String];
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
  NSDateFormatter *formatter;
  NSString        *dateString;
  
  formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
  
  dateString = [formatter stringFromDate:[NSDate date]];
  return [self MD5String:dateString];
}


@end
