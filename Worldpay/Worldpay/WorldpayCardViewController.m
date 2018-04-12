//
//  WorldpayCardViewController.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "WorldpayCardViewController.h"
#import "WorldpayUtils.h"

@interface WorldpayCardViewController ()

@property (nonatomic,copy) requestTokenSuccess saveSuccessBlock;
@property (nonatomic,copy) requestTokenFailure saveFailureBlock;
@property (nonatomic) BOOL isModal, shouldDeleteCharacter;
@property (nonatomic, strong) UIImageView *cardTypeImageView;
@property (nonatomic, strong) UIColor *colorTheme;
@property (nonatomic) BOOL isDisplayingError;

/*!
 *  The 5 textfields required to fill in the card details.
 */

@property (nonatomic) UITextField *firstName;
@property (nonatomic) UITextField *lastName;
@property (nonatomic) UITextField *cardNumber;
@property (nonatomic) UITextField *expiry;
@property (nonatomic) UITextField *CVC;

@end

@implementation WorldpayCardViewController {
    UIView *backgroundView, *containerView;
    UIView *backgroundLoadingView;
    UIActivityIndicatorView *actIndView;
    
    CGRect screenRect;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (instancetype)initWithTheme:(CardDetailsTheme)theme loadingTheme:(CardDetailsLoadingTheme)loadingTheme {
    if (self = [super init]) {
        _theme = theme;
        _loadingTheme = loadingTheme;
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _loadingTheme = CardDetailsLoadingThemeWhite;
        _colorTheme = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        _isDisplayingError = NO;
    }
    
    return self;
}

- (instancetype)initWithColor:(UIColor *)color loadingTheme:(CardDetailsLoadingTheme)loadingTheme {
    if (self = [super init]) {
        _colorTheme = color;
        _loadingTheme = loadingTheme;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    screenRect = [UIScreen mainScreen].bounds;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1];
    
    [self createNavigationBar];
    
    [self initGUI];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    
    [WorldpayUtils loadFont:@"ArialMT"];
    
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

- (void)createNavigationBar {
    
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    toolbar.translucent = NO;
    [self.view addSubview:toolbar];
    
    toolbar.tintColor = _colorTheme;
    toolbar.barTintColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:243/255.0];
    
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
    title.text = @"Card Details";
    title.font = [UIFont boldSystemFontOfSize:16];
    UIBarButtonItem *barTitle = [[UIBarButtonItem alloc] initWithCustomView:title];
    [title sizeToFit];
    [items addObject:barTitle];
    
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:spacer2];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [saveButton setTitle:@"Save Card" forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [saveButton setTitleColor:toolbar.tintColor forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(saveCardAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *toolbarSaveButton = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    [items addObject:toolbarSaveButton];
    [saveButton sizeToFit];
    
    toolbar.items = items;
}

- (void)showWarningView {
    
    [_firstName resignFirstResponder];
    [_lastName resignFirstResponder];
    [_expiry resignFirstResponder];
    [_CVC resignFirstResponder];
    [_cardNumber resignFirstResponder];
    
    _firstName.textColor = [UIColor blackColor];
    _lastName.textColor = [UIColor blackColor];
    _cardNumber.textColor = [UIColor blackColor];
    _expiry.textColor = [UIColor blackColor];
    _CVC.textColor = [UIColor blackColor];
    
    
    backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    backgroundView.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.7);
    backgroundView.alpha = 0;
    backgroundView.userInteractionEnabled = YES;
    
    [self.view addSubview:backgroundView];
    
    containerView = [[UIView alloc]initWithFrame:CGRectMake((screenRect.size.width/2)-140, (backgroundView.frame.size.height-208)/2, 280, 208)];
    
    UIImageView *padlockImage = [[UIImageView alloc]initWithFrame:CGRectMake(40, 20, 22, 28)];
    
    UIButton *btnConfirm = [[UIButton alloc]initWithFrame:CGRectMake((containerView.frame.size.width-90)/2, containerView.frame.size.height - 50, 90, 37)];
    
    
    [btnConfirm setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    btnConfirm.titleLabel.font = [UIFont systemFontOfSize:14];
    btnConfirm.layer.cornerRadius = 5;
    [btnConfirm addTarget:self action:@selector(closeWarningView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (_loadingTheme == CardDetailsLoadingThemeWhite) {
        btnConfirm.backgroundColor = [UIColor grayColor];
        [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnConfirm.titleLabel.textColor = [UIColor whiteColor];
        containerView.backgroundColor = UIColorFromRGBWithAlpha(0xFFFFFF, 1.0);
        padlockImage.image = [UIImage imageNamed:@"WorldpayResources.bundle/lockB.png"];
    } else {
        btnConfirm.backgroundColor = [UIColor whiteColor];
        [btnConfirm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        containerView.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 1.0);
        padlockImage.image = [UIImage imageNamed:@"WorldpayResources.bundle/lockW.png"];
    }
    [backgroundView addSubview:containerView];
    [containerView addSubview:btnConfirm];
    
    containerView.layer.cornerRadius = 10;
    [containerView addSubview:padlockImage];
    
    UILabel *secureAndSafeLabel = [[UILabel alloc]initWithFrame:CGRectMake(68, 21, screenRect.size.width-55, 30)];
    secureAndSafeLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:25];
    
    secureAndSafeLabel.textColor = [UIColor colorWithRed:0.224 green:0.224 blue:0.224 alpha:1];
    secureAndSafeLabel.text = @"Secure & safe";
    
    UILabel *secureAndSafeDescription1 = [[UILabel alloc]initWithFrame:CGRectMake(10, secureAndSafeLabel.frame.origin.y+35, containerView.frame.size.width-20, 50)];
    secureAndSafeDescription1.text = NSLocalizedString(@"Before we transmit your card details, we encrypt them using SSL.", nil);
    secureAndSafeDescription1.font = [UIFont fontWithName:@"ArialMT" size:16];
    secureAndSafeDescription1.lineBreakMode = NO;
    secureAndSafeDescription1.numberOfLines = 0;
    
    UILabel *secureAndSafeDescription2 = [[UILabel alloc]initWithFrame:CGRectMake(10, secureAndSafeDescription1.frame.origin.y+45, containerView.frame.size.width-20, 50)];
    secureAndSafeDescription2.text = NSLocalizedString(@"And we don't store your card details on this device.", nil);
    secureAndSafeDescription2.lineBreakMode = NO;
    secureAndSafeDescription2.font = [UIFont fontWithName:@"ArialMT" size:16];
    secureAndSafeDescription2.numberOfLines = 0;
    
    if (_loadingTheme == CardDetailsLoadingThemeBlack) {
        secureAndSafeLabel.textColor = [UIColor whiteColor];
        secureAndSafeDescription1.textColor = [UIColor whiteColor];
        secureAndSafeDescription2.textColor = [UIColor whiteColor];
    }
    
    [containerView addSubview:secureAndSafeLabel];
    [containerView addSubview:secureAndSafeDescription1];
    [containerView addSubview:secureAndSafeDescription2];
    
    [backgroundView addSubview:containerView];
    float xPos = containerView.frame.origin.x;
    containerView.frame = CGRectMake(xPos, containerView.frame.origin.y, containerView.frame.size.width, containerView.frame.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        self->backgroundView.alpha = 1;
    }];
}

- (IBAction)closeWarningView:(id)sender {
    
    [UIView animateWithDuration:0.2 animations:^{
        self->backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self->backgroundView removeFromSuperview];
    }];
}

- (void)addLoadingBackground {
    [_firstName resignFirstResponder];
    [_lastName resignFirstResponder];
    [_expiry resignFirstResponder];
    [_CVC resignFirstResponder];
    [_cardNumber resignFirstResponder];
    
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

- (void)setSaveButtonTapBlockWithSuccess:(requestTokenSuccess)success
                                 failure:(requestTokenFailure)failure {
    _saveSuccessBlock = success;
    _saveFailureBlock = failure;
}

- (IBAction)backAction:(id)sender {
    [self closeController];
}

- (IBAction)saveCardAction:(id)sender{
    
    NSArray *expirationDateParts = [_expiry.text componentsSeparatedByString:@"/"];
    NSString *expirationMonth = nil;
    NSString *expirationYear = nil;
    
    if (expirationDateParts.count == 2) {
        expirationMonth = expirationDateParts[0];
        expirationYear = expirationDateParts[1];
    }
    
    NSArray *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:[NSString stringWithFormat:@"%@%@",_firstName.text,_lastName.text]
                                                                        cardNumber:_cardNumber.text
                                                                   expirationMonth:expirationMonth
                                                                    expirationYear:expirationYear
                                                                               CVC:_CVC.text];
    if (errors.count > 0) {
        
        UILabel *errorMessage = [[UILabel alloc]initWithFrame:CGRectMake(0,230,screenRect.size.width,20)];
        errorMessage.textColor = [UIColor redColor];
        errorMessage.textAlignment = NSTextAlignmentCenter;
        
        BOOL cardNumberValid = YES;
        BOOL expiryDateValid = YES;
        BOOL cardHolderNameValid = YES;
        BOOL cvcValid = YES;
        NSString *expiryDateErrorMsg, *cardNumberErrorMsg, *cardHolderNameErrorMsg, *cvcErrorMsg;
        
        for (NSError *error in errors) {
            switch (error.code) {
                case 1:
                    [self shakeTextField:CardDetailsTextFieldExpiry];
                    expiryDateValid = NO;
                    expiryDateErrorMsg = error.localizedDescription;
                    break;
                case 2:
                    [self shakeTextField:CardDetailsTextFieldCardNumber];
                    cardNumberValid = NO;
                    cardNumberErrorMsg = error.localizedDescription;
                    break;
                case 3:
                    [self shakeTextField:CardDetailsTextFieldFirstName];
                    [self shakeTextField:CardDetailsTextFieldLastName];
                    cardHolderNameErrorMsg = error.localizedDescription;
                    cardHolderNameValid = NO;
                    break;
                case 4:
                    [self shakeTextField:CardDetailsTextFieldCVC];
                    cvcErrorMsg = error.localizedDescription;
                    cvcValid = NO;
                    break;
                default:
                    break;
            }
        }
        //display error message here
        if (!_isDisplayingError) {
            if (!cardHolderNameValid) {
                errorMessage.text = cardHolderNameErrorMsg;
            } else if (!cardNumberValid) {
                errorMessage.text = cardNumberErrorMsg;
            } else if (!expiryDateValid) {
                errorMessage.text = expiryDateErrorMsg;
            } else if (!cvcValid) {
                errorMessage.text = cvcErrorMsg;
            }
            
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
                 self->_isDisplayingError = YES;
                 if (finished) {
                     [UIView animateWithDuration:0.5 delay:2.5 options:UIViewAnimationOptionCurveLinear
                                      animations:^{
                                          errorMessage.alpha = 0;
                                      } completion:^(BOOL finished){
                                          self->_isDisplayingError = NO;
                                      }];
                 }
             }];
        }
        
    }
    else {
        [self addLoadingBackground];
        
        __weak WorldpayCardViewController *weakSelf = self;
        
        NSArray *dateParts = [_expiry.text componentsSeparatedByString:@"/"];
        
        [[Worldpay sharedInstance] createTokenWithNameOnCard:[NSString stringWithFormat:@"%@ %@",_firstName.text, _lastName.text]
                                                  cardNumber:_cardNumber.text
                                             expirationMonth:dateParts[0]
                                              expirationYear:dateParts[1]
                                                         CVC:_CVC.text
                                                     success:^(NSInteger code, NSDictionary *responseDictionary) {
                                                         [weakSelf closeController];
                                                         self->_saveSuccessBlock(responseDictionary);
                                                     }
                                                     failure:^(id responseData, NSArray *errors) {
                                                         [weakSelf closeController];
                                                         self->_saveFailureBlock(responseData, errors);
                                                     }];
        
        
    }
}

- (void)initGUI {
    UIView *bg1 = [[UIView alloc]initWithFrame:CGRectMake(0, 64, screenRect.size.width, 101)];
    bg1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg1];
    
    UIView *bg2 = [[UIView alloc]initWithFrame:CGRectMake(0, 165, screenRect.size.width/2, 51)];
    bg2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg2];
    
    _firstName = [[UITextField alloc]initWithFrame:CGRectMake(10, 64, (screenRect.size.width/2) - 20, 50)];
    _firstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"First Name", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    [self.view addSubview:_firstName];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(screenRect.size.width/2, 64, 1, 50)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line1];
    
    _lastName = [[UITextField alloc]initWithFrame:CGRectMake((screenRect.size.width/2)+10, 64, (screenRect.size.width/2) - 20, 50)];
    _lastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Last Name", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    [self.view addSubview:_lastName];
    
    UIView *horizontalLine0 = [[UIView alloc]initWithFrame:CGRectMake(0, 64, screenRect.size.width, 1)];
    horizontalLine0.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
    [self.view addSubview:horizontalLine0];
    
    
    UIView *horizontalLine1 = [[UIView alloc]initWithFrame:CGRectMake(10, _lastName.frame.size.height+_lastName.frame.origin.y, screenRect.size.width - 10, 1)];
    horizontalLine1.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    [self.view addSubview:horizontalLine1];
    
    _cardNumber = [[UITextField alloc]initWithFrame:CGRectMake(60, horizontalLine1.frame.origin.y+1, screenRect.size.width - 10, 50)];
    _cardNumber.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Card Number", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    _cardNumber.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.view addSubview:_cardNumber];
    
    _cardTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, _cardNumber.frame.origin.y + 5, 40, 40)];
    _cardTypeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"WorldpayResources.bundle/default_card.png"]];;
    _cardTypeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_cardTypeImageView];
    
    UIView *horizontalLine2 = [[UIView alloc]initWithFrame:CGRectMake(10, _cardNumber.frame.size.height+_cardNumber.frame.origin.y, screenRect.size.width - 10, 1)];
    horizontalLine2.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    [self.view addSubview:horizontalLine2];
    
    _expiry = [[UITextField alloc]initWithFrame:CGRectMake(10, horizontalLine2.frame.origin.y+1, screenRect.size.width/3.5, 50)];
    _expiry.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"MM/YYYY", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    _expiry.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_expiry];
    
    UIView *line4 = [[UIView alloc]initWithFrame:CGRectMake((screenRect.size.width/3.5) + 10, horizontalLine2.frame.origin.y+1, 1, 50)];
    line4.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line4];
    
    _CVC = [[UITextField alloc]initWithFrame:CGRectMake((screenRect.size.width/3.5) + 20, horizontalLine2.frame.origin.y+1, screenRect.size.width/4, 50)];
    _CVC.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CVC", nil) attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    _CVC.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.view addSubview:_CVC];
    
    UIView *line5 = [[UIView alloc]initWithFrame:CGRectMake(screenRect.size.width/2, horizontalLine2.frame.origin.y+1, 1, 50)];
    line5.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line5];
    
    UIView *horizontalLine3 = [[UIView alloc]initWithFrame:CGRectMake(0, _expiry.frame.size.height+_expiry.frame.origin.y, (screenRect.size.width/2)+1, 1)];
    horizontalLine3.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
    [self.view addSubview:horizontalLine3];
    
    UILabel *secureAndSafe = [[UILabel alloc]initWithFrame:CGRectMake(line5.frame.origin.x+(screenRect.size.width/25), horizontalLine2.frame.origin.y+15, 115, 20)];
    secureAndSafe.text = @"Secure & safe";
    secureAndSafe.userInteractionEnabled = YES;
    
    [secureAndSafe addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(padLockAction:)]];
    
    [self.view addSubview:secureAndSafe];
    
    UIImageView *padlock = [[UIImageView alloc]initWithFrame:CGRectMake(secureAndSafe.frame.size.width+secureAndSafe.frame.origin.x, horizontalLine2.frame.origin.y+15, 20, 20)];
    
    UIImage *padLockImage = [UIImage imageNamed:@"WorldpayResources.bundle/lockB.png"];
    
    [UITextField appearance].tintColor = _colorTheme;
    padlock.image = [self filledImageFrom:padLockImage withColor:_colorTheme];
    padlock.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:padlock];
    padlock.userInteractionEnabled = YES;
    [padlock addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(padLockAction:)]];
    
    _firstName.returnKeyType = UIReturnKeyNext;
    _lastName.returnKeyType = UIReturnKeyNext;
    _cardNumber.returnKeyType = UIReturnKeyNext;
    _expiry.returnKeyType = UIReturnKeyNext;
    _CVC.returnKeyType = UIReturnKeyDone;
    
    _firstName.layer.name = @"firstName";
    _lastName.layer.name = @"lastName";
    _cardNumber.layer.name = @"cardNumber";
    _expiry.layer.name = @"expiry";
    _CVC.layer.name = @"CVC";
    
    _firstName.delegate = self;
    _lastName.delegate = self;
    _cardNumber.delegate = self;
    _expiry.delegate = self;
    _CVC.delegate = self;
    
    
    _cardNumber.keyboardType = UIKeyboardTypeDecimalPad;
    _expiry.keyboardType = UIKeyboardTypeDecimalPad;
    _CVC.keyboardType = UIKeyboardTypeDecimalPad;
    
    [_cardNumber addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_expiry addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_CVC addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [_firstName addTarget:self action:@selector(firstNameSetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [_lastName addTarget:self action:@selector(lastNameSetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingDidBegin];
    [_cardNumber addTarget:self action:@selector(cardNumberSetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [_expiry addTarget:self action:@selector(expirySetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [_CVC addTarget:self action:@selector(CVCSetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [_firstName addTarget:self action:@selector(firstNameSetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [_lastName addTarget:self action:@selector(lastNameSetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [_cardNumber addTarget:self action:@selector(cardNumberSetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [_expiry addTarget:self action:@selector(expirySetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingDidEnd];
    [_CVC addTarget:self action:@selector(CVCSetBlackTextOnEditingChanged:) forControlEvents:UIControlEventEditingDidEnd];
}

- (IBAction)padLockAction:(id)sender {
    [self showWarningView];
}

- (void)shakeTextField:(CardDetailsTextField)textField{
    if(textField == CardDetailsTextFieldFirstName){
        [self shake:_firstName shakes:0 direction:1];
    }else if(textField == CardDetailsTextFieldLastName){
        [self shake:_lastName shakes:0 direction:1];
    }else if(textField == CardDetailsTextFieldCardNumber){
        [self shake:_cardNumber shakes:0 direction:1];
    }else if(textField == CardDetailsTextFieldExpiry){
        [self shake:_expiry shakes:0 direction:1];
    }else if(textField == CardDetailsTextFieldCVC){
        [self shake:_CVC shakes:0 direction:1];
    }
}

- (void)shake:(UITextField *)theOneYouWannaShake shakes:(int)shakes direction:(int)direction {
    __block int shakesNumber = shakes;
    __block int directionNumber = shakes;
    
    [UIView animateWithDuration:0.05 animations:^
     {
         theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(5*direction, 0);
     }
                     completion:^(BOOL finished)
     {
         if(shakes >= 10)
         {
             theOneYouWannaShake.textColor = [UIColor redColor];
             theOneYouWannaShake.transform = CGAffineTransformIdentity;
             return;
         }
         shakesNumber++;
         directionNumber = direction * -1;
         [self shake:theOneYouWannaShake shakes:shakesNumber direction:directionNumber];
     }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField.layer.name isEqualToString:@"expiry"]){
        [textField selectAll:self];
    }
}

- (IBAction)textFieldDidChange:(id)sender{
    _cardNumber.text = [_cardNumber.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    _expiry.text = [_expiry.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    _CVC.text = [_CVC.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString *cardType = [[Worldpay sharedInstance] cardType:[_cardNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    BOOL isValidCard = ([Worldpay sharedInstance].validationType == WorldpayValidationTypeBasic &&
                        [[Worldpay sharedInstance] validateCardNumberBasicWithCardNumber:_cardNumber.text]) ||
    ([Worldpay sharedInstance].validationType == WorldpayValidationTypeAdvanced &&
     [[Worldpay sharedInstance] validateCardNumberAdvancedWithCardNumber:_cardNumber.text]);
    
    if (![cardType isEqualToString:@"unknown"] && isValidCard) {
        _cardTypeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"WorldpayResources.bundle/%@.png", cardType]];
    }
    else {
        _cardTypeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"WorldpayResources.bundle/default_card.png"]];;
    }
    
    if (sender == _expiry && _expiry.text.length == 2 && _expiry.text.length == 2 && [_expiry.text characterAtIndex:1] != '/' && !_shouldDeleteCharacter) {
        _expiry.text = [NSString stringWithFormat:@"%@/", _expiry.text];
    }
    
    NSInteger cardLength = [_cardNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""].length;
    
    if (sender == _cardNumber && cardLength != 16 && cardLength % 4 == 0 && [_cardNumber.text characterAtIndex:cardLength-1] != ' ' && !_shouldDeleteCharacter) {
        _cardNumber.text = [NSString stringWithFormat:@"%@ ", _cardNumber.text];
    }
    _shouldDeleteCharacter = NO;
    
}

-(IBAction)firstNameSetBlackTextOnEditingChanged:(id)sender{
    _firstName.textColor = [UIColor blackColor];
}

-(IBAction)lastNameSetBlackTextOnEditingChanged:(id)sender{
    _lastName.textColor = [UIColor blackColor];
}

-(IBAction)cardNumberSetBlackTextOnEditingChanged:(id)sender{
    _cardNumber.textColor = [UIColor blackColor];
}

-(IBAction)expirySetBlackTextOnEditingChanged:(id)sender{
    _expiry.textColor = [UIColor blackColor];
}

-(IBAction)CVCSetBlackTextOnEditingChanged:(id)sender{
    _CVC.textColor = [UIColor blackColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.layer.name isEqualToString:@"firstName"]){
        [_lastName becomeFirstResponder];
    }else if([textField.layer.name isEqualToString:@"lastName"]){
        [_cardNumber becomeFirstResponder];
    }else if([textField.layer.name isEqualToString:@"cardNumber"]){
        [_expiry becomeFirstResponder];
    }else if([textField.layer.name isEqualToString:@"expiry"]){
        [_CVC becomeFirstResponder];
    }else{
        [_CVC resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([string isEqualToString:@""]) {
        _shouldDeleteCharacter = YES;
    }
    
    if (textField == _cardNumber && _cardNumber.text.length > 18 && string.length != 0) {
        return NO;
    }
    
    if ([string isEqualToString:@","]) {
        return NO;
    }
    
    if(textField == _expiry && string.length != 0 && ![string isEqualToString:@"/"] && (_expiry.text).length == 2 && [_expiry.text rangeOfString:@"/"].location == NSNotFound) {
        _expiry.text = [NSString stringWithFormat:@"%@/", _expiry.text];
    }
    
    if (textField == _cardNumber && string.length != 0 && _cardNumber.text.length != 0 && ![[_cardNumber.text substringFromIndex:_cardNumber.text.length-1] isEqualToString:@" "] && [_cardNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""].length % 4 == 0) {
        _cardNumber.text = [NSString stringWithFormat:@"%@ ", _cardNumber.text];
    }
    
    if (textField.text.length >= 7 && range.length == 0 && [textField.layer.name isEqualToString:@"expiry"]){
        return NO;
    } else if(textField.text.length >= 4 && range.length == 0 && [textField.layer.name isEqualToString:@"CVC"]){
        return NO;
    }
    
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
    if (_isModal) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
