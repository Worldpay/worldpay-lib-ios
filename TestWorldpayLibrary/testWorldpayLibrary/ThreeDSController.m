//
//  ThreeDSController.m
//  testWorldpayLibrary
//
//  Created by Vasilis Panagiotopoulos on 8/25/15.
//  Copyright (c) 2015 arx. All rights reserved.
//

#import "ThreeDSController.h"
#import "Worldpay.h"
#import "AFNetworking.h"
#import "ALToastView.h"
#import "AppDelegate.h"
#import "SuccessPageViewController.h"
#import "BasketManager.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CommonCrypto/CommonDigest.h>

#define TempURL "http://ios.worldpay.io/rsp.php"

@interface ThreeDSController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *currentOrderCode;
@property (nonatomic, retain) AppDelegate *delegate;
@property (nonatomic, retain) NSString *sessionID;
@end

@implementation ThreeDSController

-(void)createNavigationBar{
  UIView *navigationBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen]bounds].size.width, 40)];
  navigationBarView.backgroundColor = [UIColor colorWithRed:0.941 green:0.118 blue:0.078 alpha:1];
  [self.view addSubview:navigationBarView];
  
  UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
  [backBtn setTitle:@"Back" forState:UIControlStateNormal];
  [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
  [navigationBarView addSubview:backBtn];
  
  UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(100, 10, 117, 22)];
  [logo setImage:[UIImage imageNamed:@"logo.png"]];
  [navigationBarView addSubview:logo];
  
  _sessionID = [self uniqueSessionID];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self createNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [self initializeThreeDS];
    [ALToastView toastInView:_delegate.window withText:@"Loading 3DS authentication site..."];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        NSLog(@"JSON: %@", responseObject);
      
      if ([[responseObject objectForKey:@"paymentStatus"] isEqualToString:@"FAILED"]) {
        [ALToastView toastInView:_delegate.window withText:[NSString stringWithFormat:@"Payment failed, status: %@", [responseObject objectForKey:@"paymentStatusReason"]]];
        [self.navigationController popViewControllerAnimated:YES];
      } else {
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
      
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ALToastView toastInView:_delegate.window withText:@"An error occured. Check console for logs"];
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",ErrorResponse);    }];
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

- (void)generateOrderCodeWithOrderCode:(NSString *)orderCode
                                 paRes:(NSString *)paRes
                               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
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
    [op setCompletionBlockWithSuccess:success failure:failure];
    [[NSOperationQueue mainQueue] addOperation:op];
}



#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", request.URL.absoluteString);
    if ([request.URL.absoluteString containsString:@"worldpay-scheme://"]) {
        NSString *paRes = [self paramFromURL:request.URL.absoluteString key:@"PaRes"];
        
        [self generateOrderCodeWithOrderCode:_currentOrderCode
                                       paRes:paRes success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           NSString *status = [operation.responseObject objectForKey:@"paymentStatus"];
                                           if ([status isEqualToString:@"SUCCESS"]) {
                                               SuccessPageViewController *vc = [[SuccessPageViewController alloc] init];
                                             [[BasketManager sharedInstance] clearBasket];
                                               [self.navigationController pushViewController:vc animated:YES];
                                           } else {
                                               [self.navigationController popViewControllerAnimated:YES];
                                               [ALToastView toastInView:_delegate.window withText:[NSString stringWithFormat:@"Payment failed, status: %@", status]];
                                           }
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           [self.navigationController popViewControllerAnimated:YES];
                                           [ALToastView toastInView:_delegate.window withText:@"An error occured. Check console for logs"];
                                           NSLog(@"%@", operation.responseObject);
                                       }];
    }
    return YES;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
