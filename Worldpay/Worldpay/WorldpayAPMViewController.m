//
//  WorldpayAPMViewController.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "WorldpayAPMViewController.h"
#import "APMController.h"
#import "WorldpayResourcesManager.h"

@interface WorldpayAPMViewController () <UITextFieldDelegate>

@property (nonatomic, copy) createAPMOrderSuccess saveSuccessBlock;
@property (nonatomic, copy) createAPMOrderFailure saveFailureBlock;

@property (nonatomic, assign) BOOL isModal, shouldDeleteCharacter;
@property (nonatomic, copy  ) UIColor *colorTheme;
@property (nonatomic, assign) BOOL isDisplayingError;

/*!
 *  The textfields required to fill in the APM details.
 */

// UI FIELDS
@property (nonatomic, weak) UITextField *apmNameInput;
@property (nonatomic, weak) UITextField *priceInput;
@property (nonatomic, weak) UITextField *addressInput;
@property (nonatomic, weak) UITextField *cityInput;
@property (nonatomic, weak) UITextField *postcodeInput;
@property (nonatomic, weak) UITextField *nameInput;
@property (nonatomic, weak) UITextField *countryCodeInput;
@property (nonatomic, weak) UITextField *settlementCurrencyInput;
@property (nonatomic, weak) UITextField *currencyInput;
@property (nonatomic, weak) UITextField *successUrlInput;
@property (nonatomic, weak) UITextField *cancelUrlInput;
@property (nonatomic, weak) UITextField *failureUrlInput;
@property (nonatomic, weak) UITextField *pendingUrlInput;
@property (nonatomic, weak) UITextField *shopperLanguageCodeInput;
@property (nonatomic, weak) UITextField *swiftCodeInput;
@property (nonatomic, weak) UITextField *customerOrderCodeInput;
@property (nonatomic, weak) UITextField *descriptionInput;

@end

@implementation WorldpayAPMViewController{
    UIView *backgroundView, *containerView;
    UIView *backgroundLoadingView;
    UIActivityIndicatorView *actIndView;
    
    CGRect screenRect;
}

- (instancetype)init {
    if (self = [self initWithAPMName:nil]) {
    }
    
    return self;
}

- (instancetype)initWithAPMName:(NSString *)apmName {
    if (self = [self initWithColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]
                      loadingTheme:APMDetailsLoadingThemeWhite
                           apmName:apmName]) {
    }
    
    return self;
}

- (instancetype)initWithColor:(UIColor *)color loadingTheme:(APMDetailsLoadingTheme)loadingTheme apmName:(NSString *)apmName {
    if (self = [super init]) {
        _apmName = apmName;
        _colorTheme = color;
        _loadingTheme = loadingTheme;
        _isDisplayingError = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    screenRect = [UIScreen mainScreen].bounds;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1];
    
    [self createNavigationBar];
    [self initGUI];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isBeingPresented) {
        _isModal = YES;
    }
    else {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)createNavigationBar{
    
    if (_customToolbar) {
        [self.view addSubview:_customToolbar];
        return;
    }
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    toolbar.translucent = NO;
    
    toolbar.tintColor = _colorTheme;
    toolbar.barTintColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:243/255.0];
    [self.view addSubview:toolbar];
    
    UIView *statusBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    statusBackgroundView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:243/255.0];
    [self.view addSubview:statusBackgroundView];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -18, 0, 0);
    UIImage *arrowImage = [WorldpayResourcesManager wp_filledImageFrom:[WorldpayResourcesManager wp_imageNamed:@"wp_ic_back_arrow"]
                                               withColor:toolbar.tintColor];
    UIImage *arrowHover = [WorldpayResourcesManager wp_filledImageFrom:[WorldpayResourcesManager wp_imageNamed:@"wp_ic_back_arrow"]
                                               withColor:[UIColor lightGrayColor]];
    
    [backButton setImage:arrowImage forState:UIControlStateNormal];
    [backButton setImage:arrowHover forState:UIControlStateHighlighted];
    [backButton setTitleColor:toolbar.tintColor forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *toolbarBackButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [items addObject:toolbarBackButton];
    
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:spacer1];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 20)];
    title.text = @"APM Details";
    title.font = [UIFont boldSystemFontOfSize:16];
    UIBarButtonItem *barTitle = [[UIBarButtonItem alloc] initWithCustomView:title];
    [title sizeToFit];
    [items addObject:barTitle];
    
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:spacer2];
    
    toolbar.items = items;
}


- (void)addLoadingBackground {
    [_apmNameInput resignFirstResponder];
    [_priceInput resignFirstResponder];
    [_addressInput resignFirstResponder];
    [_nameInput resignFirstResponder];
    [_currencyInput resignFirstResponder];
    [_successUrlInput resignFirstResponder];
    [_pendingUrlInput resignFirstResponder];
    [_cancelUrlInput resignFirstResponder];
    [_failureUrlInput resignFirstResponder];
    [_shopperLanguageCodeInput resignFirstResponder];
    [_swiftCodeInput resignFirstResponder];
    [_countryCodeInput resignFirstResponder];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    backgroundLoadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    backgroundLoadingView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
    [self.view addSubview:backgroundLoadingView];
    
    actIndView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actIndView.color = [UIColor whiteColor];
    [actIndView startAnimating];
    actIndView.frame = CGRectMake(screenRect.size.width/2-25, screenRect.size.height/2-25, 50, 50);
    [backgroundLoadingView addSubview:actIndView];
}

- (void)removeLoadingBackground{
    [backgroundView removeFromSuperview];
    [backgroundLoadingView removeFromSuperview];
    [actIndView removeFromSuperview];
}

- (void)setCreateAPMOrderBlockWithSuccess:(createAPMOrderSuccess)success
                                  failure:(createAPMOrderFailure)failure {
    _saveSuccessBlock = success;
    _saveFailureBlock = failure;
}

- (IBAction)backAction:(id)sender {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    [errors addObject:[[Worldpay sharedInstance] errorWithTitle:NSLocalizedString(@"User cancelled APM order", nil) code:0]];
    _saveFailureBlock(@{}, errors);
    [self closeController];
}

- (IBAction)submitAPMDetails:(id)sender{
    
    NSArray *errors = [[Worldpay sharedInstance] validateAPMDetailsWithAPMName:_apmName countryCode:_countryCodeInput.text];
    NSString *errorMessage = @"";
    
    if (errors.count > 0) {
        BOOL countryCodeValid = YES;
        BOOL apmNameValid = YES;
        NSString *countryCodeErrorMsg, *apmNameErrorMsg;
        
        for (NSError *error in errors) {
            switch (error.code) {
                case 1:
                    apmNameValid = NO;
                    apmNameErrorMsg = error.localizedDescription;
                    break;
                case 2:
                    countryCodeValid = NO;
                    countryCodeErrorMsg = error.localizedDescription;
                    break;
                default:
                    break;
            }
        }
        
        if (!_isDisplayingError) {
            if (!apmNameValid) {
                errorMessage = apmNameErrorMsg;
            }
            else if (!countryCodeValid) {
                errorMessage = countryCodeErrorMsg;
            }
            
            [self displayAlertMessage:errorMessage];
        }
        
    }
    else {
        [self addLoadingBackground];
        
        NSDictionary *apmFields = [[NSDictionary alloc] init];
        NSString *_shopperLangCode = nil;
        NSString *countryCode = (_countryCode) ? _countryCode : _countryCodeInput.text;
        
        if ([_apmName.lowercaseString isEqualToString:@"paypal"]) {
            _shopperLangCode = (_shopperLanguageCode) ? _shopperLanguageCode : _shopperLanguageCodeInput.text;
        }
        else if ([_apmName.lowercaseString isEqualToString:@"giropay"]) {
            apmFields = @{@"swiftCode" : (_swiftCode) ? _swiftCode : _swiftCodeInput.text };
        }
        
        //We create an APM token here
        __weak typeof(self) weak = self;
        [[Worldpay sharedInstance] createAPMTokenWithAPMName:_apmName countryCode:countryCode apmFields:apmFields shopperLanguageCode:_shopperLangCode
                                                     success:^(NSInteger code, NSDictionary *responseDictionary) {
                                                         
                                                         APMController *apmController = [[APMController alloc] init];
                                                         
                                                         apmController.address = (weak.address) ? weak.address : weak.addressInput.text;
                                                         apmController.countryCode = (weak.countryCode) ? weak.countryCode : weak.countryCodeInput.text;
                                                         apmController.city = (weak.city) ? weak.city : weak.cityInput.text;
                                                         apmController.currencyCode = (weak.currency) ? weak.currency : weak.currencyInput.text;
                                                         apmController.settlementCurrency = (weak.settlementCurrency) ? weak.settlementCurrency : weak.settlementCurrencyInput.text;
                                                         apmController.postalCode = (weak.postcode) ? weak.postcode : weak.postcodeInput.text;
                                                         apmController.token = responseDictionary[@"token"];
                                                         apmController.name = (weak.name) ? weak.name : weak.nameInput.text;
                                                         apmController.price = (weak.price) ? weak.price : (weak.priceInput.text).floatValue;
                                                         apmController.successUrl = (weak.successUrl) ? weak.successUrl : weak.successUrlInput.text;
                                                         apmController.failureUrl = (weak.failureUrl) ? weak.failureUrl : weak.failureUrlInput.text;
                                                         apmController.cancelUrl = (weak.cancelUrl) ? weak.cancelUrl : weak.cancelUrlInput.text;
                                                         apmController.pendingUrl = (weak.pendingUrl) ? weak.pendingUrl : weak.pendingUrlInput.text;
                                                         
                                                         apmController.customerOrderCode = (weak.customerOrderCode) ?  weak.customerOrderCode : weak.customerOrderCodeInput.text;
                                                         
                                                         apmController.customerIdentifiers = (weak.customerIdentifiers && weak.customerIdentifiers.count > 0) ? weak.customerIdentifiers : @{};
                                                         //
                                                         apmController.orderDescription = (weak.orderDescription) ? weak.orderDescription : weak.descriptionInput.text;
                                                         
                                                         ///Once the authorize order is completed, we call these code blocks
                                                         [apmController setAuthorizeAPMOrderBlockWithSuccess:^(NSDictionary *responseDictionary) {
                                                             [weak removeLoadingBackground];
                                                             weak.saveSuccessBlock(responseDictionary);
                                                             
                                                         } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                             [weak removeLoadingBackground];
                                                             weak.saveFailureBlock(responseDictionary, errors);
                                                         }];
                                                         
                                                         if (weak.navigationController) {
                                                             [weak.navigationController pushViewController:apmController animated:YES];
                                                         }
                                                         else {
                                                             [weak presentViewController:apmController animated:YES completion:nil];
                                                         }
                                                         
                                                     }
                                                     failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                         [weak removeLoadingBackground];
                                                         [weak displayAlertMessage:@"There was an error creating the token!"];
                                                         
                                                         NSError *err = errors[0];
                                                         NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)err.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                                         
                                                         NSLog(@"%@",ErrorResponse);
                                                     }];
    }
}

- (void)displayAlertMessage:(NSString *)message {
    
    UILabel *errorMessage = [[UILabel alloc]initWithFrame:CGRectMake(0,64,screenRect.size.width,40)];
    errorMessage.textColor = [UIColor whiteColor];
    errorMessage.backgroundColor = _colorTheme;
    errorMessage.textAlignment = NSTextAlignmentCenter;
    errorMessage.text = message;
    errorMessage.alpha = 0.0;
    
    [self.view addSubview:errorMessage];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         errorMessage.alpha = 1;
                     }
                     completion:^(BOOL finished)
     {
         self.isDisplayingError = YES;
         if (finished) {
             [UIView animateWithDuration:0.5 delay:2.5 options:UIViewAnimationOptionCurveLinear
                              animations:^{
                                  errorMessage.alpha = 0;
                              }
                              completion:^(BOOL finished) {
                                  self.isDisplayingError = NO;
                              }];
         }
     }];
    
}

- (void)addHorizontalLineOnView:(UIScrollView *)scrollView afterElement:(UITextField *)element {
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(0, element.frame.size.height+element.frame.origin.y, screenRect.size.width, 1)];
    horizontalLine.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
    [scrollView addSubview:horizontalLine];
}

- (void)initGUI {
    
    NSUInteger numberOfFields = 13;
    NSUInteger fieldHeight = 40;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, screenRect.size.width, 78 * numberOfFields)];
    
    UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(0, 10, screenRect.size.width, 49.5 * numberOfFields)];
    bg.backgroundColor = (_loadingTheme == APMDetailsLoadingThemeBlack) ? [UIColor blackColor] : [UIColor whiteColor];
    [scrollView addSubview:bg];
    
    UITextField *apmNameInput = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, screenRect.size.width - 10, 40)];
    apmNameInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"APM Name", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    apmNameInput.text = [NSLocalizedString(@"APM Name: ", nil) stringByAppendingString:_apmName];
    apmNameInput.enabled = NO;
    [scrollView addSubview:apmNameInput];
    _apmNameInput = apmNameInput;
    
    [self addHorizontalLineOnView:scrollView afterElement:_apmNameInput];
    
    UITextField *priceInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _apmNameInput.frame.size.height+_apmNameInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    priceInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Total Price", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    
    if (_price > 0.0) {
        priceInput.enabled = NO;
        priceInput.text = [NSLocalizedString(@"Total Price: ", nil) stringByAppendingString:[NSString stringWithFormat:@"%.2f", _price]];
    }
    [scrollView addSubview:priceInput];
    _priceInput = priceInput;
    [self addHorizontalLineOnView:scrollView afterElement:_priceInput];
    
    UITextField *addressInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _priceInput.frame.size.height+_priceInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    addressInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Address", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    
    if (_address.length) {
        addressInput.text = [NSLocalizedString(@"Address: ",nil) stringByAppendingString:_address];
        addressInput.enabled = NO;
    }
    [scrollView addSubview:addressInput];
    _addressInput = addressInput;
    [self addHorizontalLineOnView:scrollView afterElement:_addressInput];
    
    UITextField *cityInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _addressInput.frame.size.height+_addressInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    cityInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"City", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    
    if (_city.length) {
        cityInput.text = [NSLocalizedString(@"City: ",nil) stringByAppendingString:_city];
        cityInput.enabled = NO;
    }
    [scrollView addSubview:cityInput];
    _cityInput = cityInput;
    [self addHorizontalLineOnView:scrollView afterElement:_cityInput];
    
    UITextField *postcodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _cityInput.frame.size.height+_cityInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    postcodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Postcode", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    
    if (_postcode.length) {
        postcodeInput.text = [NSLocalizedString(@"Postcode: ",nil) stringByAppendingString:_postcode];
        postcodeInput.enabled = NO;
    }
    [scrollView addSubview:postcodeInput];
    _postcodeInput = postcodeInput;
    [self addHorizontalLineOnView:scrollView afterElement:_postcodeInput];
    
    UITextField *descriptionInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _postcodeInput.frame.size.height+_postcodeInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    descriptionInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Order Description", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_orderDescription.length) {
        descriptionInput.enabled = NO;
        descriptionInput.text = [NSLocalizedString(@"Description: ",nil) stringByAppendingString:_orderDescription];
    }
    [scrollView addSubview:descriptionInput];
    _descriptionInput = descriptionInput;
    [self addHorizontalLineOnView:scrollView afterElement:_descriptionInput];
    
    UITextField *countryCodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _descriptionInput.frame.size.height+_descriptionInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    countryCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Country Code (Eg. 'GB')", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_countryCode.length) {
        countryCodeInput.enabled = NO;
        countryCodeInput.text = [NSLocalizedString(@"Country Code: ",nil) stringByAppendingString:_countryCode];
    }
    [scrollView addSubview:countryCodeInput];
    _countryCodeInput = countryCodeInput;
    [self addHorizontalLineOnView:scrollView afterElement:_countryCodeInput];
    
    if ([_apmName.lowercaseString isEqualToString:@"paypal"]) {
        UITextField *shopperLanguageCodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _countryCodeInput.frame.size.height+_countryCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
        shopperLanguageCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Language Code (Eg. 'EN')", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        if (_shopperLanguageCode.length) {
            shopperLanguageCodeInput.enabled = NO;
            shopperLanguageCodeInput.text = [NSLocalizedString(@"Language Code: ",nil) stringByAppendingString:_shopperLanguageCode];
        }
        [scrollView addSubview:shopperLanguageCodeInput];
        _shopperLanguageCodeInput = shopperLanguageCodeInput;
        [self addHorizontalLineOnView:scrollView afterElement:_shopperLanguageCodeInput];
        
        UITextField *currencyInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _shopperLanguageCodeInput.frame.size.height+_shopperLanguageCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
        currencyInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Currency (Eg. 'GBP')", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        if (_currency.length) {
            currencyInput.enabled = NO;
            currencyInput.text = [NSLocalizedString(@"Currency: ",nil) stringByAppendingString:_currency];
        }
        [scrollView addSubview:currencyInput];
        _currencyInput = currencyInput;
    }
    
    if ([_apmName.lowercaseString isEqualToString:@"giropay"]) {
        
        UITextField *swiftCodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _countryCodeInput.frame.size.height+_countryCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
        _swiftCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Swift Code", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        if (_swiftCode) {
            swiftCodeInput.enabled = NO;
            swiftCodeInput.text = [NSLocalizedString(@"Swift Code: ",nil) stringByAppendingString:_swiftCode];
        }
        [scrollView addSubview:swiftCodeInput];
        _swiftCodeInput = swiftCodeInput;
        [self addHorizontalLineOnView:scrollView afterElement:_swiftCodeInput];
        
        UITextField *currencyInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _swiftCodeInput.frame.size.height+_swiftCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
        currencyInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Currency (Eg. 'GBP')", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        
        if (_currency.length) {
            currencyInput.enabled = NO;
            currencyInput.text = [NSLocalizedString(@"Currency: ",nil) stringByAppendingString:_currency];
        }
        [scrollView addSubview:currencyInput];
        _currencyInput = currencyInput;
    }
    
    [self addHorizontalLineOnView:scrollView afterElement:_currencyInput];
    
    UITextField *settlementCurrencyInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _currencyInput.frame.size.height+_currencyInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    settlementCurrencyInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Settlement Currency", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_settlementCurrency.length) {
        settlementCurrencyInput.enabled = NO;
        settlementCurrencyInput.text = [NSLocalizedString(@"Settlement Currency: ",nil) stringByAppendingString:_settlementCurrency];
    }
    
    [scrollView addSubview:settlementCurrencyInput];
    _settlementCurrencyInput = settlementCurrencyInput;
    [self addHorizontalLineOnView:scrollView afterElement:_settlementCurrencyInput];
    
    UITextField *nameInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _settlementCurrencyInput.frame.size.height+_settlementCurrencyInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    nameInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Name", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_name.length) {
        nameInput.enabled = NO;
        nameInput.text = [NSLocalizedString(@"Name: ",nil) stringByAppendingString:_name];
    }
    [scrollView addSubview:nameInput];
    _nameInput = nameInput;
    [self addHorizontalLineOnView:scrollView afterElement:_nameInput];
    
    UITextField *customerOrderCodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _nameInput.frame.size.height+_nameInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    customerOrderCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Customer Order Code", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_customerOrderCode.length) {
        customerOrderCodeInput.enabled = NO;
        customerOrderCodeInput.text = [NSLocalizedString(@"Order Code: ",nil) stringByAppendingString:_customerOrderCode];
    }
    [scrollView addSubview:customerOrderCodeInput];
    _customerOrderCodeInput = customerOrderCodeInput;
    [self addHorizontalLineOnView:scrollView afterElement:_customerOrderCodeInput];
    
    UITextField *successUrlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _customerOrderCodeInput.frame.size.height+_customerOrderCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
    successUrlInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Success URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_successUrl.length) {
        successUrlInput.enabled = NO;
        successUrlInput.text = [NSLocalizedString(@"Success URL: ",nil) stringByAppendingString:_successUrl];
    }
    [scrollView addSubview:successUrlInput];
    _successUrlInput = successUrlInput;
    [self addHorizontalLineOnView:scrollView afterElement:_successUrlInput];
    
    UITextField *cancelUrlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _successUrlInput.frame.size.height+_successUrlInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
    cancelUrlInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Cancel URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_cancelUrl.length) {
        cancelUrlInput.enabled = NO;
        cancelUrlInput.text = [NSLocalizedString(@"Cancel URL: ",nil) stringByAppendingString:_cancelUrl];
    }
    [scrollView addSubview:cancelUrlInput];
    _cancelUrlInput = cancelUrlInput;
    [self addHorizontalLineOnView:scrollView afterElement:_cancelUrlInput];
    
    UITextField *failureUrlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _cancelUrlInput.frame.size.height+_cancelUrlInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
    failureUrlInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Failure URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_failureUrl.length) {
        failureUrlInput.enabled = NO;
        failureUrlInput.text = [NSLocalizedString(@"Failure URL: ",nil) stringByAppendingString:_failureUrl];
    }
    [scrollView addSubview:failureUrlInput];
    _failureUrlInput = failureUrlInput;
    [self addHorizontalLineOnView:scrollView afterElement:_failureUrlInput];
    
    UITextField *pendingUrlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _failureUrlInput.frame.size.height+_failureUrlInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
    pendingUrlInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pending URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_pendingUrl.length) {
        pendingUrlInput.enabled = NO;
        pendingUrlInput.text = [NSLocalizedString(@"Pending URL: ",nil) stringByAppendingString:_pendingUrl];
    }
    [scrollView addSubview:pendingUrlInput];
    _pendingUrlInput = pendingUrlInput;
    
    UIButton *confirmPurchase = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width/2-85, scrollView.frame.size.height-320, 160, 35)];
    
    if (!_confirmPurchaseButton) {
        confirmPurchase.titleLabel.font = [UIFont systemFontOfSize:13];
        [confirmPurchase setTitle:@"Confirm Purchase" forState:UIControlStateNormal];
        confirmPurchase.backgroundColor = [UIColor colorWithRed:0 green:0.471 blue:0.404 alpha:1];
        confirmPurchase.layer.cornerRadius = 5.0f;
    }
    else {
        confirmPurchase = _confirmPurchaseButton;
    }
    
    [confirmPurchase addTarget:self action:@selector(submitAPMDetails:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:confirmPurchase];
    
    scrollView.contentSize = CGSizeMake(screenRect.size.width, 115 * numberOfFields);
    
    [self.view addSubview:scrollView];
    
    [UITextField appearance].tintColor = _colorTheme;
    
    _apmNameInput.layer.name                = @"apmName";
    _priceInput.layer.name                  = @"price";
    _addressInput.layer.name                = @"address";
    _cityInput.layer.name                   = @"city";
    _postcodeInput.layer.name               = @"postcode";
    _countryCodeInput.layer.name            = @"countryCode";
    _nameInput.layer.name                   = @"name";
    _successUrlInput.layer.name             = @"successUrl";
    _failureUrlInput.layer.name             = @"failureUrl";
    _cancelUrlInput.layer.name              = @"cancelUrl";
    _pendingUrlInput.layer.name             = @"pendingUrl";
    _currencyInput.layer.name               = @"currency";
    _shopperLanguageCodeInput.layer.name    = @"shopperLanguageCode";
    _swiftCodeInput.layer.name              = @"swiftCode";
    _descriptionInput.layer.name            = @"description";
    _settlementCurrencyInput.layer.name     = @"settlementCurrency";
    _customerOrderCodeInput.layer.name      = @"customerOrderCode";
    
    _apmNameInput.delegate              = self;
    _priceInput.delegate                = self;
    _addressInput.delegate              = self;
    _cityInput.delegate                 = self;
    _postcodeInput.delegate             = self;
    _countryCodeInput.delegate          = self;
    _nameInput.delegate                 = self;
    _successUrlInput.delegate           = self;
    _failureUrlInput.delegate           = self;
    _cancelUrlInput.delegate            = self;
    _pendingUrlInput.delegate           = self;
    _currencyInput.delegate             = self;
    _shopperLanguageCodeInput.delegate  = self;
    _swiftCodeInput.delegate            = self;
    _descriptionInput.delegate          = self;
    _settlementCurrencyInput.delegate   = self;
    _customerOrderCodeInput.delegate    = self;
    
    if (_loadingTheme == APMDetailsLoadingThemeBlack) {
        _apmNameInput.textColor             = [UIColor whiteColor];
        _priceInput.textColor               = [UIColor whiteColor];
        _addressInput.textColor             = [UIColor whiteColor];
        _cityInput.textColor                = [UIColor whiteColor];
        _postcodeInput.textColor            = [UIColor whiteColor];
        _countryCodeInput.textColor         = [UIColor whiteColor];
        _nameInput.textColor                = [UIColor whiteColor];
        _successUrlInput.textColor          = [UIColor whiteColor];
        _failureUrlInput.textColor          = [UIColor whiteColor];
        _cancelUrlInput.textColor           = [UIColor whiteColor];
        _pendingUrlInput.textColor          = [UIColor whiteColor];
        _currencyInput.textColor            = [UIColor whiteColor];
        _shopperLanguageCodeInput.textColor = [UIColor whiteColor];
        _swiftCodeInput.textColor           = [UIColor whiteColor];
        _descriptionInput.textColor         = [UIColor whiteColor];
        _settlementCurrencyInput.textColor  = [UIColor whiteColor];
        _customerOrderCodeInput.textColor   = [UIColor whiteColor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_apmNameInput resignFirstResponder];
    [_priceInput resignFirstResponder];
    [_addressInput resignFirstResponder];
    [_cityInput resignFirstResponder];
    [_postcodeInput resignFirstResponder];
    [_nameInput resignFirstResponder];
    [_countryCodeInput resignFirstResponder];
    [_currencyInput resignFirstResponder];
    [_successUrlInput resignFirstResponder];
    [_pendingUrlInput resignFirstResponder];
    [_cancelUrlInput resignFirstResponder];
    [_failureUrlInput resignFirstResponder];
    [_shopperLanguageCodeInput resignFirstResponder];
    [_swiftCodeInput resignFirstResponder];
    
    return YES;
}

- (void)closeController {
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
