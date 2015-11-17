//
//  APMController.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "APMController.h"
#import "Worldpay.h"
#import <AFNetworking/AFNetworking.h>

@interface APMController ()<UIWebViewDelegate>

@property (nonatomic,copy) authorizeAPMOrderSuccess authorizeSuccessBlock;
@property (nonatomic,copy) authorizeAPMOrderFailure authorizeFailureBlock;

@property (nonatomic, retain) NSString *currentOrderCode;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation APMController

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


}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavigationBar];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,50,self.view.frame.size.width,self.view.frame.size.height-_customToolbar.frame.size.height)];
    _webView.delegate = self;

    [self.view addSubview:_webView];
    
//    any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated {
    [self initializeAPM];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark - APM Methods

- (void)initializeAPM {
    NSString *stringURL = [[[Worldpay sharedInstance] APIStringURL] stringByAppendingPathComponent:@"orders"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:[[Worldpay sharedInstance] serviceKey] forHTTPHeaderField:@"Authorization"];

    NSDictionary *params = @{
                             @"token": _token,
                             @"orderDescription": _orderDescription,
                             @"amount": @((NSInteger)(_price * 100)),
                             @"currencyCode": _currencyCode,
                             @"name": _name,
                             @"billingAddress": @{
                                     @"address1": _address,
                                     @"postalCode": _postalCode,
                                     @"city": _city,
                                     @"countryCode": _countryCode
                                     },
                             @"customerIdentifiers": _customerIdentifiers,
                             @"customerOrderCode": _customerOrderCode,
                             @"is3DSOrder": @(NO),
                             @"successUrl": _successUrl,
                             @"pendingUrl": _pendingUrl,
                             @"failureUrl": _failureUrl,
                             @"cancelUrl": _cancelUrl
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
          
          //Refresh URLS in case the user doesn't input any urls on create order
          _successUrl = [responseObject objectForKey:@"successUrl"];
          _failureUrl = [responseObject objectForKey:@"failureUrl"];
          _cancelUrl = [responseObject objectForKey:@"cancelUrl"];
          _pendingUrl = [responseObject objectForKey:@"pendingUrl"];
          
          [self redirectToAPMPageWithRedirectURL:[responseObject objectForKey:@"redirectURL"]];

      } else {
          NSMutableArray *errors = [[NSMutableArray alloc] init];
          [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"There was an error creating the APM Order.", nil) code:1]];
          
          
          _authorizeFailureBlock(operation.responseObject, errors);
      }
      
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSMutableArray *errors = [[NSMutableArray alloc] init];

        [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"There was an error creating the APM Order.", nil) code:1]];
        _authorizeFailureBlock(operation.responseObject, errors);
        
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];

}

- (void)redirectToAPMPageWithRedirectURL:(NSString *)redirectURL {
    NSURL *url = [NSURL URLWithString:redirectURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"GET"];
    
    [_webView loadRequest: request];
}

- (void)setAuthorizeAPMOrderBlockWithSuccess:(authorizeAPMOrderSuccess)success
                                  failure:(authorizeAPMOrderFailure)failure {
    _authorizeSuccessBlock = success;
    _authorizeFailureBlock = failure;
}

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSDictionary *responseDictionary = @{
                                         @"token": _token,
                                         @"orderCode": _currentOrderCode
                                };
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    //we need to tell the parent controller that the purchase was success
    if ([request.URL.absoluteString containsString:_successUrl]) {
        _authorizeSuccessBlock(responseDictionary);
    }
    else if ([request.URL.absoluteString containsString:_failureUrl]){
        [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"There was an error authorizing the APM Order. Order failed.", nil) code:1]];
        _authorizeFailureBlock(responseDictionary, errors);
    }
    else if ([request.URL.absoluteString containsString:_cancelUrl]){
        [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"There was an error authorizing the APM Order. Order cancelled.", nil) code:2]];
        _authorizeFailureBlock(responseDictionary, errors);
    }
    else if ([request.URL.absoluteString containsString:_pendingUrl]){
        [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"There was an error authorizing the APM Order. Order pending.", nil) code:3]];
        _authorizeFailureBlock(responseDictionary, errors);
    }
    
    return YES;
}


@end
