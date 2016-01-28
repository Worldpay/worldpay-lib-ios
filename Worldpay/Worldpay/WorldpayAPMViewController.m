//
//  WorldpayAPMViewController.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "WorldpayAPMViewController.h"
#import "WorldpayUtils.h"
#import "APMController.h"
#import <AFNetworking/AFNetworking.h>

@interface WorldpayAPMViewController ()

@property (nonatomic,copy) createAPMOrderSuccess saveSuccessBlock;
@property (nonatomic,copy) createAPMOrderFailure saveFailureBlock;

@property (nonatomic) BOOL isModal, shouldDeleteCharacter;
@property (nonatomic, retain) UIColor *colorTheme;
@property (nonatomic) BOOL isDisplayingError;

/*!
 *  The textfields required to fill in the APM details.
 */

// UI FIELDS
@property (nonatomic) UITextField *apmNameInput;
@property (nonatomic) UITextField *priceInput;
@property (nonatomic) UITextField *addressInput;
@property (nonatomic) UITextField *cityInput;
@property (nonatomic) UITextField *postcodeInput;
@property (nonatomic) UITextField *nameInput;
@property (nonatomic) UITextField *countryCodeInput;
@property (nonatomic) UITextField *settlementCurrencyInput;
@property (nonatomic) UITextField *currencyInput;
@property (nonatomic) UITextField *successUrlInput;
@property (nonatomic) UITextField *cancelUrlInput;
@property (nonatomic) UITextField *failureUrlInput;
@property (nonatomic) UITextField *pendingUrlInput;
@property (nonatomic) UITextField *shopperLanguageCodeInput;
@property (nonatomic) UITextField *swiftCodeInput;
@property (nonatomic) UITextField *customerOrderCodeInput;
@property (nonatomic) UITextField *descriptionInput;

@end

@implementation WorldpayAPMViewController{
    UIView *backgroundView, *containerView;
    UIView *backgroundLoadingView;
    UIActivityIndicatorView *actIndView;
    
    CGRect screenRect;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id)init {
    if (self = [super init]) {
        _loadingTheme = APMDetailsLoadingThemeWhite;
        _colorTheme = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        _isDisplayingError = NO;
        
    }
    return self;
}

-(id)initWithAPMName:(NSString *)apmName {
    _apmName = apmName;
    _loadingTheme = APMDetailsLoadingThemeWhite;
    _colorTheme = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    return self;
}

-(id)initWithColor:(UIColor *)color loadingTheme:(APMDetailsLoadingTheme)loadingTheme apmName:(NSString *)apmName {
    _apmName = apmName;
    _colorTheme = color;
    _loadingTheme = loadingTheme;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    screenRect = [[UIScreen mainScreen]bounds];
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1];
    
    [self createNavigationBar];
    [self initGUI];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    
    [WorldpayUtils loadFont:@"ArialMT"];

}

- (void)viewWillAppear:(BOOL)animated {
    if (self.isBeingPresented) {
        _isModal = YES;
    } else {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

-(void)createNavigationBar{
        
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
    UIImage *arrowImage = [self filledImageFrom:[UIImage imageNamed:@"WorldpayResources.bundle/back_arrow.png"] withColor:toolbar.tintColor];
    UIImage *arrowHover = [self filledImageFrom:[UIImage imageNamed:@"WorldpayResources.bundle/back_arrow.png"] withColor:[UIColor lightGrayColor]];
    
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
    
    [toolbar setItems:items];
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
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
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
        
        for(NSError *error in errors) {
            switch (error.code) {
                case 1:
                    apmNameValid = NO;
                    apmNameErrorMsg = [error localizedDescription];
                    break;
                case 2:
                    countryCodeValid = NO;
                    countryCodeErrorMsg = [error localizedDescription];
                    break;
                default:
                    break;
            }
        }
        
        if (!_isDisplayingError) {
            if (!apmNameValid) {
                errorMessage = apmNameErrorMsg;
            } else if (!countryCodeValid) {
                errorMessage = countryCodeErrorMsg;
            }
            
            [self displayAlertMessage:errorMessage];
        }

    } else {
        [self addLoadingBackground];
        
        NSDictionary *apmFields = [[NSDictionary alloc] init];
        NSString *_shopperLangCode = nil;
        NSString *countryCode = (_countryCode) ? _countryCode : _countryCodeInput.text;

        if ([[_apmName lowercaseString] isEqualToString:@"paypal"]) {
            _shopperLangCode = (_shopperLanguageCode) ? _shopperLanguageCode : _shopperLanguageCodeInput.text;
        }
        else if ([[_apmName lowercaseString] isEqualToString:@"giropay"]) {
            apmFields = @{@"swiftCode" : (_swiftCode) ? _swiftCode : _swiftCodeInput.text };
        }

        //We create an APM token here
        [[Worldpay sharedInstance] createAPMTokenWithAPMName:_apmName countryCode:countryCode apmFields:apmFields shopperLanguageCode:_shopperLangCode
                                                    success:^(int code, NSDictionary *responseDictionary) {
            
                                                        APMController *apmController = [[APMController alloc] init];

                                                        apmController.address = (_address) ? _address : _addressInput.text;
                                                        apmController.countryCode = (_countryCode) ? _countryCode : _countryCodeInput.text;
                                                        apmController.city = (_city) ? _city : _cityInput.text;
                                                        apmController.currencyCode = (_currency) ? _currency : _currencyInput.text;
                                                        apmController.settlementCurrency = (_settlementCurrency) ? _settlementCurrency : _settlementCurrencyInput.text;
                                                        apmController.postalCode = (_postcode) ? _postcode : _postcodeInput.text;
                                                        apmController.token = [responseDictionary objectForKey:@"token"];
                                                        apmController.name = (_name) ? _name : _nameInput.text;
                                                        apmController.price = (_price) ? _price : [_priceInput.text floatValue];
                                                        apmController.successUrl = (_successUrl) ? _successUrl : _successUrlInput.text;
                                                        apmController.failureUrl = (_failureUrl) ? _failureUrl : _failureUrlInput.text;
                                                        apmController.cancelUrl = (_cancelUrl) ? _cancelUrl : _cancelUrlInput.text;
                                                        apmController.pendingUrl = (_pendingUrl) ? _pendingUrl : _pendingUrlInput.text;
                                                        
                                                        apmController.customerOrderCode = (_customerOrderCode) ?  _customerOrderCode : _customerOrderCodeInput.text;
                                                        
                                                        apmController.customerIdentifiers = (_customerIdentifiers && [_customerIdentifiers count] > 0) ? _customerIdentifiers : @{};
//
                                                        apmController.orderDescription = (_orderDescription) ? _orderDescription : _descriptionInput.text;
                                                        
                                                        ///Once the authorize order is completed, we call these code blocks
                                                        [apmController setAuthorizeAPMOrderBlockWithSuccess:^(NSDictionary *responseDictionary) {
                                                            [self removeLoadingBackground];
                                                            _saveSuccessBlock(responseDictionary);

                                                        } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                            [self removeLoadingBackground];
                                                            _saveFailureBlock(responseDictionary, errors);
                                                        }];
                                                        
                                                        if (self.navigationController) {
                                                            [self.navigationController pushViewController:apmController animated:YES];
                                                        }
                                                        else {
                                                            [self presentViewController:apmController animated:YES completion:nil];
                                                        }
            
                                                     }
                                                     failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                        [self removeLoadingBackground];
                                                        [self displayAlertMessage:@"There was an error creating the token!"];
                                                         
                                                         NSError *err = [errors objectAtIndex:0];
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
    errorMessage.alpha = 0;

    [self.view addSubview:errorMessage];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         errorMessage.alpha = 1;
                     }
                     completion:^(BOOL finished)
     {
         _isDisplayingError = YES;
         if (finished) {
             [UIView animateWithDuration:0.5 delay:2.5 options:UIViewAnimationOptionCurveLinear
                              animations:^{
                                  errorMessage.alpha = 0;
                              }completion:^(BOOL finished){
                                  _isDisplayingError = NO;
                              }];
         }
     }];

}

- (void)addHorizontalLineOnView:(UIScrollView *)scrollView afterElement:(UITextField *)element {
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(0, element.frame.size.height+element.frame.origin.y, screenRect.size.width, 1)];
    horizontalLine.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
    [scrollView addSubview:horizontalLine];
}

- (void)initGUI{
    
    int numberOfFields = 13;
    int fieldHeight = 40;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, screenRect.size.width, 78 * numberOfFields)];
    
    UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(0, 10, screenRect.size.width, 49.5 * numberOfFields)];
    bg.backgroundColor = (_loadingTheme == APMDetailsLoadingThemeBlack) ? [UIColor blackColor] : [UIColor whiteColor];
    [scrollView addSubview:bg];
    
    _apmNameInput = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, screenRect.size.width - 10, 40)];
    _apmNameInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"APM Name", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    _apmNameInput.text = [NSLocalizedString(@"APM Name: ",nil) stringByAppendingString:_apmName];
    _apmNameInput.enabled = NO;
    [scrollView addSubview:_apmNameInput];
    
    [self addHorizontalLineOnView:scrollView afterElement:_apmNameInput];
    
    _priceInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _apmNameInput.frame.size.height+_apmNameInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    _priceInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Total Price", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];

    if (_price) {
        _priceInput.enabled = NO;
        _priceInput.text = [NSLocalizedString(@"Total Price: ",nil) stringByAppendingString:[NSString stringWithFormat:@"%.2f", _price]];
    }
    [scrollView addSubview:_priceInput];

    [self addHorizontalLineOnView:scrollView afterElement:_priceInput];

    _addressInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _priceInput.frame.size.height+_priceInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    _addressInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Address", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];

    if (_address) {
        _addressInput.text = [NSLocalizedString(@"Address: ",nil) stringByAppendingString:_address];
        _addressInput.enabled = NO;
    }
    [scrollView addSubview:_addressInput];

    [self addHorizontalLineOnView:scrollView afterElement:_addressInput];

    _cityInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _addressInput.frame.size.height+_addressInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    _cityInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"City", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];

    if (_city) {
        _cityInput.text = [NSLocalizedString(@"City: ",nil) stringByAppendingString:_city];
        _cityInput.enabled = NO;
    }
    [scrollView addSubview:_cityInput];

    [self addHorizontalLineOnView:scrollView afterElement:_cityInput];
    
    _postcodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _cityInput.frame.size.height+_cityInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    _postcodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Postcode", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];

    if (_postcode) {
        _postcodeInput.text = [NSLocalizedString(@"Postcode: ",nil) stringByAppendingString:_postcode];
        _postcodeInput.enabled = NO;
    }
    [scrollView addSubview:_postcodeInput];
    
    [self addHorizontalLineOnView:scrollView afterElement:_postcodeInput];
    
    _descriptionInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _postcodeInput.frame.size.height+_postcodeInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    _descriptionInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Order Description", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_orderDescription) {
        _descriptionInput.enabled = NO;
        _descriptionInput.text = [NSLocalizedString(@"Description: ",nil) stringByAppendingString:_orderDescription];
    }
    [scrollView addSubview:_descriptionInput];
    
    [self addHorizontalLineOnView:scrollView afterElement:_descriptionInput];

    _countryCodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _descriptionInput.frame.size.height+_descriptionInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    _countryCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Country Code (Eg. 'GB')", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_countryCode) {
        _countryCodeInput.enabled = NO;
        _countryCodeInput.text = [NSLocalizedString(@"Country Code: ",nil) stringByAppendingString:_countryCode];
    }
    [scrollView addSubview:_countryCodeInput];
    
    [self addHorizontalLineOnView:scrollView afterElement:_countryCodeInput];
    
    
    if ([[_apmName lowercaseString] isEqualToString:@"paypal"]) {
        _shopperLanguageCodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _countryCodeInput.frame.size.height+_countryCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
        _shopperLanguageCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Language Code (Eg. 'EN')", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        if (_shopperLanguageCode) {
            _shopperLanguageCodeInput.enabled = NO;
            _shopperLanguageCodeInput.text = [NSLocalizedString(@"Language Code: ",nil) stringByAppendingString:_shopperLanguageCode];
        }
        [scrollView addSubview:_shopperLanguageCodeInput];
        [self addHorizontalLineOnView:scrollView afterElement:_shopperLanguageCodeInput];
        
        _currencyInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _shopperLanguageCodeInput.frame.size.height+_shopperLanguageCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
        _currencyInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Currency (Eg. 'GBP')", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        if (_currency) {
            _currencyInput.enabled = NO;
            _currencyInput.text = [NSLocalizedString(@"Currency: ",nil) stringByAppendingString:_currency];
        }
        [scrollView addSubview:_currencyInput];
    }
    if ([[_apmName lowercaseString] isEqualToString:@"giropay"]) {
        
        _swiftCodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _countryCodeInput.frame.size.height+_countryCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
        _swiftCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Swift Code", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        if (_swiftCode) {
            _swiftCodeInput.enabled = NO;
            _swiftCodeInput.text = [NSLocalizedString(@"Swift Code: ",nil) stringByAppendingString:_swiftCode];
        }
        [scrollView addSubview:_swiftCodeInput];
        [self addHorizontalLineOnView:scrollView afterElement:_swiftCodeInput];

        _currencyInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _swiftCodeInput.frame.size.height+_swiftCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
        _currencyInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Currency (Eg. 'GBP')", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        if (_currency) {
            _currencyInput.enabled = NO;
            _currencyInput.text = [NSLocalizedString(@"Currency: ",nil) stringByAppendingString:_currency];
        }
        [scrollView addSubview:_currencyInput];
    }

    
    [self addHorizontalLineOnView:scrollView afterElement:_currencyInput];
    
    _settlementCurrencyInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _currencyInput.frame.size.height+_currencyInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    _settlementCurrencyInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Settlement Currency", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_settlementCurrency) {
        _settlementCurrencyInput.enabled = NO;
        _settlementCurrencyInput.text = [NSLocalizedString(@"Settlement Currency: ",nil) stringByAppendingString:_settlementCurrency];
    }
    
    [scrollView addSubview:_settlementCurrencyInput];
    [self addHorizontalLineOnView:scrollView afterElement:_settlementCurrencyInput];
    
    _nameInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _settlementCurrencyInput.frame.size.height+_settlementCurrencyInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    _nameInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Name", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_name) {
        _nameInput.enabled = NO;
        _nameInput.text = [NSLocalizedString(@"Name: ",nil) stringByAppendingString:_name];
    }
    [scrollView addSubview:_nameInput];
    [self addHorizontalLineOnView:scrollView afterElement:_nameInput];

    _customerOrderCodeInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _nameInput.frame.size.height+_nameInput.frame.origin.y, screenRect.size.width - 10, fieldHeight)];
    _customerOrderCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Customer Order Code", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_customerOrderCode) {
        _customerOrderCodeInput.enabled = NO;
        _customerOrderCodeInput.text = [NSLocalizedString(@"Order Code: ",nil) stringByAppendingString:_customerOrderCode];
    }
    [scrollView addSubview:_customerOrderCodeInput];
    
    [self addHorizontalLineOnView:scrollView afterElement:_customerOrderCodeInput];
    
    _successUrlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _customerOrderCodeInput.frame.size.height+_customerOrderCodeInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
    _successUrlInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Success URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_successUrl) {
        _successUrlInput.enabled = NO;
        _successUrlInput.text = [NSLocalizedString(@"Success URL: ",nil) stringByAppendingString:_successUrl];
    }
    [scrollView addSubview:_successUrlInput];
    
    [self addHorizontalLineOnView:scrollView afterElement:_successUrlInput];
    
    _cancelUrlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _successUrlInput.frame.size.height+_successUrlInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
    _cancelUrlInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Cancel URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_cancelUrl) {
        _cancelUrlInput.enabled = NO;
        _cancelUrlInput.text = [NSLocalizedString(@"Cancel URL: ",nil) stringByAppendingString:_cancelUrl];
    }
    [scrollView addSubview:_cancelUrlInput];
    
    [self addHorizontalLineOnView:scrollView afterElement:_cancelUrlInput];

    _failureUrlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _cancelUrlInput.frame.size.height+_cancelUrlInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
    _failureUrlInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Failure URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_failureUrl) {
        _failureUrlInput.enabled = NO;
        _failureUrlInput.text = [NSLocalizedString(@"Failure URL: ",nil) stringByAppendingString:_failureUrl];
    }
    [scrollView addSubview:_failureUrlInput];
    
    [self addHorizontalLineOnView:scrollView afterElement:_failureUrlInput];

    _pendingUrlInput = [[UITextField alloc]initWithFrame:CGRectMake(10, _failureUrlInput.frame.size.height+_failureUrlInput.frame.origin.y+1, screenRect.size.width - 10, fieldHeight)];
    _pendingUrlInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pending URL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    if (_pendingUrl) {
        _pendingUrlInput.enabled = NO;
        _pendingUrlInput.text = [NSLocalizedString(@"Pending URL: ",nil) stringByAppendingString:_pendingUrl];
    }
    [scrollView addSubview:_pendingUrlInput];


    UIButton *confirmPurchase = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width/2-85, scrollView.frame.size.height-320, 160, 35)];

    if (!_confirmPurchaseButton) {
        confirmPurchase.titleLabel.font = [UIFont systemFontOfSize:13];
        [confirmPurchase setTitle:@"Confirm Purchase" forState:UIControlStateNormal];
        [confirmPurchase setBackgroundColor:[UIColor colorWithRed:0 green:0.471 blue:0.404 alpha:1]];
        confirmPurchase.layer.cornerRadius = 5.0f;
    }
    else {
        confirmPurchase = _confirmPurchaseButton;
    }
    
    [confirmPurchase addTarget:self action:@selector(submitAPMDetails:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:confirmPurchase];
    
    scrollView.contentSize = CGSizeMake(screenRect.size.width, 115*numberOfFields);

    [self.view addSubview:scrollView];
    
    [[UITextField appearance] setTintColor:_colorTheme];
    
    _apmNameInput.layer.name = @"apmName";
    _priceInput.layer.name = @"price";
    _addressInput.layer.name = @"address";
    _cityInput.layer.name = @"city";
    _postcodeInput.layer.name = @"postcode";
    _countryCodeInput.layer.name = @"countryCode";
    _nameInput.layer.name = @"name";
    _successUrlInput.layer.name = @"successUrl";
    _failureUrlInput.layer.name = @"failureUrl";
    _cancelUrlInput.layer.name = @"cancelUrl";
    _pendingUrlInput.layer.name = @"pendingUrl";
    _currencyInput.layer.name = @"currency";
    _shopperLanguageCodeInput.layer.name = @"shopperLanguageCode";
    _swiftCodeInput.layer.name = @"swiftCode";
    _descriptionInput.layer.name = @"description";
    _settlementCurrencyInput.layer.name = @"settlementCurrency";
    _customerOrderCodeInput.layer.name = @"customerOrderCode";
    
    _apmNameInput.delegate = self;
    _priceInput.delegate = self;
    _addressInput.delegate = self;
    _cityInput.delegate = self;
    _postcodeInput.delegate = self;
    _countryCodeInput.delegate = self;
    _nameInput.delegate = self;
    _successUrlInput.delegate = self;
    _failureUrlInput.delegate = self;
    _cancelUrlInput.delegate = self;
    _pendingUrlInput.delegate = self;
    _currencyInput.delegate = self;
    _shopperLanguageCodeInput.delegate = self;
    _swiftCodeInput.delegate = self;
    _descriptionInput.delegate = self;
    _settlementCurrencyInput.delegate = self;
    _customerOrderCodeInput.delegate = self;
    
    if (_loadingTheme == APMDetailsLoadingThemeBlack) {
        _apmNameInput.textColor = [UIColor whiteColor];
        _priceInput.textColor = [UIColor whiteColor];
        _addressInput.textColor = [UIColor whiteColor];
        _cityInput.textColor = [UIColor whiteColor];
        _postcodeInput.textColor = [UIColor whiteColor];
        _countryCodeInput.textColor = [UIColor whiteColor];
        _nameInput.textColor = [UIColor whiteColor];
        _successUrlInput.textColor = [UIColor whiteColor];
        _failureUrlInput.textColor = [UIColor whiteColor];
        _cancelUrlInput.textColor = [UIColor whiteColor];
        _pendingUrlInput.textColor = [UIColor whiteColor];
        _currencyInput.textColor = [UIColor whiteColor];
        _shopperLanguageCodeInput.textColor = [UIColor whiteColor];
        _swiftCodeInput.textColor = [UIColor whiteColor];
        _descriptionInput.textColor = [UIColor whiteColor];
        _settlementCurrencyInput.textColor = [UIColor whiteColor];
        _customerOrderCodeInput.textColor = [UIColor whiteColor];

    }


}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color {
    
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

- (void)closeController {
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
