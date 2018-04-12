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

@property (nonatomic, strong) NSString *currentOrderCode;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) AFURLSessionManager *networkManager;

@end

@implementation APMController

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        AFURLSessionManager *networkManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        responseSerializer.readingOptions = NSJSONReadingMutableContainers;
        networkManager.responseSerializer = responseSerializer;
        _networkManager = networkManager;
    }
    
    return self;
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
    [closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBarView addSubview:closeBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavigationBar];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,50,self.view.frame.size.width,self.view.frame.size.height-_customToolbar.frame.size.height)];
    _webView.delegate = self;
    
    [self.view addSubview:_webView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initializeAPM];
}

- (IBAction)close:(id)sender {
    
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"User cancelled APM authorization", nil) code:0]];
    _authorizeFailureBlock(@{}, errors);
    
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
    
    NSDictionary *params = @{
                             @"token": _token,
                             @"orderDescription": _orderDescription,
                             @"amount": @((float)(ceil(_price * 100))),
                             @"currencyCode": _currencyCode,
                             @"settlementCurrency": _settlementCurrency,
                             @"name": _name,
                             @"billingAddress": @{
                                     @"address1": _address,
                                     @"postalCode": _postalCode,
                                     @"city": _city,
                                     @"countryCode": _countryCode
                                     },
                             @"customerIdentifiers": (_customerIdentifiers && _customerIdentifiers.count > 0) ? _customerIdentifiers : @{},
                             @"customerOrderCode": _customerOrderCode,
                             @"is3DSOrder": @(NO),
                             @"successUrl": _successUrl,
                             @"pendingUrl": _pendingUrl,
                             @"failureUrl": _failureUrl,
                             @"cancelUrl": _cancelUrl
                             };
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST"
                                                       URLString:stringURL
                                                      parameters:params
                                                           error:nil];
    
    [request addValue:[Worldpay sharedInstance].serviceKey forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [self.networkManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([[responseObject objectForKey:@"paymentStatus"] isEqualToString:@"PRE_AUTHORIZED"]) {
            self->_currentOrderCode = [responseObject objectForKey:@"orderCode"];
            
            //Refresh URLS in case the user doesn't input any urls on create order
            self->_successUrl = [responseObject objectForKey:@"successUrl"];
            self->_failureUrl = [responseObject objectForKey:@"failureUrl"];
            self->_cancelUrl = [responseObject objectForKey:@"cancelUrl"];
            self->_pendingUrl = [responseObject objectForKey:@"pendingUrl"];
            
            [self redirectToAPMPageWithRedirectURL:[responseObject objectForKey:@"redirectURL"]];
            
        } else {
            NSMutableArray *errors = [[NSMutableArray alloc] init];
            [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"There was an error creating the APM Order.", nil) code:1]];
            
            
            self->_authorizeFailureBlock(responseObject, errors);
        }
    }];
    
    [dataTask resume];
}

- (void)redirectToAPMPageWithRedirectURL:(NSString *)redirectURL {
    NSURL *url = [NSURL URLWithString:redirectURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    request.HTTPMethod = @"GET";
    
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
