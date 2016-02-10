//
//  SampleViewController.m
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "SampleViewController.h"
#import "Worldpay.h"
#import "Worldpay+ApplePay.h"
#import "WorldpayCardViewController.h"
#import "WorldpayAPMViewController.h"
#import "DBhandler.h"
#import "FMDatabase.h"
#import "CustomGestureRecognizer.h"
#import "ALToastView.h"
#import "SuccessPageViewController.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>
#import "BasketManager.h"
#import "ThreeDSController.h"
#import "MainPageViewController.h"


@interface SampleViewController ()<PKPaymentAuthorizationViewControllerDelegate>
@property (nonatomic, retain) NSString *selectedToken;
@property (nonatomic, retain) UIAlertView *deleteCardAlertView, *confirmAlertView, *quantityAlertView, *endPointAlertView, *deleteItemAlertView;
@property (nonatomic) NSInteger selectedRowToDelete;
@property (nonatomic, retain) AppDelegate *delegate;
@property (nonatomic, retain) NSDictionary *selectedItem;
@property (nonatomic, retain) UIButton *addCardButton, *paypalButton, *giropayButton;
@end

@implementation SampleViewController {
    UITextField *textfield;
    WorldpayCardViewController *worldpaycardviewcontroller;
    WorldpayAPMViewController *worldpayapmviewcontroller;
    CGRect screenRect;
    
    UITextField *addressTextField;
    UITextField *cityTextField;
    UITextField *postcodeTextField;
    
    UIScrollView *scrollView;
    
    UIView *cardsView;
    int cardsViewStartYpos;
    int cardsViewEndYpos;
    
    UIButton *confirmPurchase, *applePayButton;
    
    NSArray *cards;
    UIImageView *selectedCard;
    BOOL isSelectedCard;
    
    NSString *token;
    NSString *name;
    NSString *maskedCardNumber;
    NSString *cardType;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    screenRect = [[UIScreen mainScreen]bounds];

    [self createNavigationBar];
    [self initGUI];
    [self createStoredCardView];

    [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];
}

- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    token = @"";
    isSelectedCard = NO;
    
    [scrollView removeFromSuperview];
    [self initGUI];
    [self createStoredCardView];
  
}

-(void)createNavigationBar{
  
    UIView *navigationBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, screenRect.size.width, 40)];
    navigationBarView.backgroundColor = [UIColor colorWithRed:0.941 green:0.118 blue:0.078 alpha:1];
    [self.view addSubview:navigationBarView];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
    [backBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(cancelCheckout:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBarView addSubview:backBtn];
    
    
    UILabel *checkoutLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 5, 120, 30)];
    checkoutLabel.textColor = [UIColor whiteColor];
    checkoutLabel.textAlignment = NSTextAlignmentCenter;
    checkoutLabel.text = @"CHECKOUT";
    [navigationBarView addSubview:checkoutLabel];
  
    UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(navigationBarView.frame.size.width-75, 10, 75, 20)];
    [settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
    [settingsButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    MainPageViewController *previousViewController = (MainPageViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
  
    [settingsButton addTarget:previousViewController action:@selector(settingsAction:) forControlEvents:UIControlEventTouchUpInside ];
    [settingsButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [navigationBarView addSubview:settingsButton];
}

-(void)initGUI{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 60, screenRect.size.width, screenRect.size.height)];
    scrollView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    scrollView.showsHorizontalScrollIndicator = NO;
    
    UIView *grayView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, 30)];
    grayView1.backgroundColor = [UIColor colorWithRed:0.569 green:0.569 blue:0.569 alpha:1];
    [scrollView addSubview:grayView1];
    
    UILabel *dishLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 20)];
    dishLabel.text = @"DISH";
    dishLabel.font = [UIFont systemFontOfSize:12];
    dishLabel.textColor = [UIColor whiteColor];
    [grayView1 addSubview:dishLabel];
    
    UILabel *quantityLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width/2-50, 5, 100, 20)];
    quantityLabel.text = @"QUANTITY";
    quantityLabel.font = [UIFont systemFontOfSize:12];
    quantityLabel.textColor = [UIColor whiteColor];
    quantityLabel.textAlignment = NSTextAlignmentCenter;
    [grayView1 addSubview:quantityLabel];
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width-60, 5, 60, 20)];
    priceLabel.text = @"PRICE";
    priceLabel.font = [UIFont systemFontOfSize:12];
    priceLabel.textColor = [UIColor whiteColor];
    [grayView1 addSubview:priceLabel];
    
    float y = grayView1.frame.size.height;
    
    for (NSDictionary *item in [[BasketManager sharedInstance] basket]) {
        UILabel *itemName = [[UILabel alloc]initWithFrame:CGRectMake(10, y+grayView1.frame.origin.y+20, 100, 20)];
        itemName.text = [item objectForKey:@"name"];
        itemName.textColor = [UIColor colorWithRed:0.902 green:0 blue:0 alpha:0.8];
        [scrollView addSubview:itemName];
        
        UILabel *quantity = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width/2-20, itemName.frame.origin.y, 40, 20)];
        quantity.text = [[item objectForKey:@"quantity"] stringValue];
        quantity.textAlignment = NSTextAlignmentCenter;
        quantity.textColor = [UIColor colorWithRed:0.902 green:0 blue:0 alpha:0.8];
        [scrollView addSubview:quantity];
        
        [quantity addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeQuantityAction:)]];
        [quantity.layer setValue:item forKey:@"item"];
        quantity.userInteractionEnabled = YES;
        
        UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width-100, itemName.frame.origin.y, 80, 20)];
        price.text = [NSString stringWithFormat:@"£%@",[item objectForKey:@"price"]];
        price.textAlignment = NSTextAlignmentCenter;
        price.textColor = [UIColor colorWithRed:0.902 green:0 blue:0 alpha:0.8];
        price.userInteractionEnabled = YES;
        
        [price.layer setValue:item forKey:@"item"];
        
        [scrollView addSubview:price];
        
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-25, y+20, 20, 20)];
        [deleteButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
        
        [scrollView addSubview:deleteButton];
        
        [deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton.layer setValue:item forKey:@"item"];
        y += 40;
    }
    
    UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width-238, y+20, 200, 20)];
    price.text = [NSString stringWithFormat:@"Total £%.2f", [[BasketManager sharedInstance] totalPrice]];
    price.textAlignment = NSTextAlignmentRight;
    price.textColor = [UIColor colorWithRed:0.902 green:0 blue:0 alpha:0.8];
    [scrollView addSubview:price];
    
    y += 40;
    
    UIView *grayView2 = [[UIView alloc]initWithFrame:CGRectMake(0, price.frame.size.height+price.frame.origin.y+20, screenRect.size.width, 30)];
    grayView2.backgroundColor = [UIColor colorWithRed:0.569 green:0.569 blue:0.569 alpha:1];
    [scrollView addSubview:grayView2];
    
    UILabel *deliveryAddress = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width/2-100, 5, 200, 20)];
    deliveryAddress.text = @"DELIVERY ADDRESS";
    deliveryAddress.textColor = [UIColor whiteColor];
    deliveryAddress.font = [UIFont systemFontOfSize:12];
    deliveryAddress.textAlignment = NSTextAlignmentCenter;
    [grayView2 addSubview:deliveryAddress];
    
    UIView *textFieldBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, grayView2.frame.size.height+grayView2.frame.origin.y, screenRect.size.width, 80)];
    textFieldBackgroundView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:textFieldBackgroundView];
    
    addressTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, screenRect.size.width-20, 40)];
    addressTextField.placeholder = @"Address";
    [textFieldBackgroundView addSubview:addressTextField];
    addressTextField.delegate = self;
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, addressTextField.frame.size.height+addressTextField.frame.origin.y, screenRect.size.width, 1)];
    line1.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    [textFieldBackgroundView addSubview:line1];
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(screenRect.size.width/2, line1.frame.origin.y+1, 1, 40)];
    line2.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    [textFieldBackgroundView addSubview:line2];
    
    cityTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, line2.frame.origin.y, 149, 40)];
    cityTextField.placeholder = @"City";
    [textFieldBackgroundView addSubview:cityTextField];
    cityTextField.delegate = self;
    
    postcodeTextField = [[UITextField alloc]initWithFrame:CGRectMake(line2.frame.origin.x+10, line2.frame.origin.y, 149, 40)];
    postcodeTextField.placeholder = @"Postcode";
    [textFieldBackgroundView addSubview:postcodeTextField];
    postcodeTextField.delegate = self;
    
    UIView *grayView3 = [[UIView alloc]initWithFrame:CGRectMake(0, textFieldBackgroundView.frame.origin.y+textFieldBackgroundView.frame.size.height, screenRect.size.width, 30)];
    grayView3.backgroundColor = [UIColor colorWithRed:0.569 green:0.569 blue:0.569 alpha:1];
    [scrollView addSubview:grayView3];
    
    UILabel *paymentMethodLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width/2-100, 5, 200, 20)];
    paymentMethodLabel.text = @"PAYMENT METHOD";
    paymentMethodLabel.font = [UIFont systemFontOfSize:14];
    paymentMethodLabel.textColor = [UIColor whiteColor];
    paymentMethodLabel.textAlignment = NSTextAlignmentCenter;
    [grayView3 addSubview:paymentMethodLabel];
    
    _addCardButton = [[UIButton alloc]initWithFrame:CGRectMake(13, grayView3.frame.size.height+grayView3.frame.origin.y+11, 140, 32)];
    [_addCardButton setTitle:@"Add card" forState:UIControlStateNormal];
    _addCardButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_addCardButton setBackgroundColor:[UIColor colorWithRed:0.569 green:0.569 blue:0.569 alpha:1]];
    _addCardButton.layer.cornerRadius = 5.0f;
    [_addCardButton addTarget:self action:@selector(addCardAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:_addCardButton];
    
    
    UILabel *storedCards = [[UILabel alloc]initWithFrame:CGRectMake(10, _addCardButton.frame.size.height+_addCardButton.frame.origin.y+50, 100, 20)];
    storedCards.font = [UIFont systemFontOfSize:14];
    storedCards.textColor = [UIColor grayColor];
    storedCards.text = @"Stored Cards";
    [scrollView addSubview:storedCards];
    
    cardsViewStartYpos = storedCards.frame.size.height+storedCards.frame.origin.y+10;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *address = [prefs stringForKey:@"address"];
    
    if(address==nil){
        [prefs setObject:addressTextField.text forKey:@"address"];
        [prefs setObject:cityTextField.text forKey:@"city"];
        [prefs setObject:postcodeTextField.text forKey:@"postcode"];
    }else{
        addressTextField.text = [prefs stringForKey:@"address"];
        cityTextField.text = [prefs stringForKey:@"city"];
        postcodeTextField.text = [prefs stringForKey:@"postcode"];
    }
    
    confirmPurchase = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width/2-80, scrollView.frame.size.height-110, 160, 35)];
    [confirmPurchase setTitle:@"Confirm Purchase" forState:UIControlStateNormal];
    confirmPurchase.titleLabel.font = [UIFont systemFontOfSize:13];
    [confirmPurchase setBackgroundColor:[UIColor colorWithRed:0 green:0.471 blue:0.404 alpha:1]];
    confirmPurchase.layer.cornerRadius = 5.0f;
    [confirmPurchase addTarget:self action:@selector(confirmPurchaseAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:confirmPurchase];

    applePayButton = [[UIButton alloc]initWithFrame:CGRectMake(_addCardButton.frame.size.width + _addCardButton.frame.origin.x + 13, _addCardButton.frame.origin.y, 140, 32)];
    [applePayButton setImage:[UIImage imageNamed:@"apple_pay_btn.png"] forState:UIControlStateNormal];
    [applePayButton addTarget:self action:@selector(applePayTap) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:applePayButton];

    
    addressTextField.returnKeyType = UIReturnKeyNext;
    postcodeTextField.returnKeyType = UIReturnKeyDone;
    cityTextField.returnKeyType = UIReturnKeyNext;
    
    addressTextField.layer.name = @"address";
    postcodeTextField.layer.name = @"postcode";
    cityTextField.layer.name = @"city";
    
    //Paypal button
    _paypalButton = [[UIButton alloc]initWithFrame:CGRectMake(13, grayView3.frame.size.height+grayView3.frame.origin.y+51, 140, 32)];
    [_paypalButton setTitle:@"Buy with Paypal" forState:UIControlStateNormal];
    _paypalButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_paypalButton setBackgroundColor:[UIColor colorWithRed:0.569 green:0.569 blue:0.569 alpha:1]];
    _paypalButton.layer.cornerRadius = 5.0f;
    [_paypalButton addTarget:self action:@selector(editPaypalSettingsAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:_paypalButton];

    //Giropay Button
    _giropayButton = [[UIButton alloc]initWithFrame:CGRectMake(_addCardButton.frame.size.width + _addCardButton.frame.origin.x + 13, grayView3.frame.size.height+grayView3.frame.origin.y+51, 140, 32)];
    [_giropayButton setTitle:@"Buy with Giropay" forState:UIControlStateNormal];
    _giropayButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_giropayButton setBackgroundColor:[UIColor colorWithRed:0.569 green:0.569 blue:0.569 alpha:1]];
    _giropayButton.layer.cornerRadius = 5.0f;
    [_giropayButton addTarget:self action:@selector(editGiropaySettingsAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:_giropayButton];
    
    [self.view addSubview:scrollView];
}


-(IBAction)cancelCheckout:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)editPaypalSettingsAction:(id)sender {
    [self editAPMSettingsAction:@"Paypal"];
}
-(IBAction)editGiropaySettingsAction:(id)sender {
    [self editAPMSettingsAction:@"Giropay"];
}

-(IBAction)editAPMSettingsAction:(NSString *)apmName {
    
    [self saveDeliveryAddressDefaults];
    
    NSString *billingAddressErrorMessage = @"";
    if([addressTextField.text isEqualToString:@""]){
        billingAddressErrorMessage = [billingAddressErrorMessage stringByAppendingString:@"Please fill in address\n"];
    }
    if([cityTextField.text isEqualToString:@""]){
        billingAddressErrorMessage = [billingAddressErrorMessage stringByAppendingString:@"Please fill in city\n"];
    }
    if([postcodeTextField.text isEqualToString:@""]){
        billingAddressErrorMessage = [billingAddressErrorMessage stringByAppendingString:@"Please fill in postal code\n"];
    }
    
    if(![billingAddressErrorMessage isEqualToString:@""]){
        [ALToastView toastInView:self.view withText:billingAddressErrorMessage];
        [confirmPurchase setUserInteractionEnabled:YES];
        return;
    }
    
    worldpayapmviewcontroller = [[WorldpayAPMViewController alloc] initWithColor:[UIColor redColor] loadingTheme:APMDetailsLoadingThemeWhite apmName:apmName];

    worldpayapmviewcontroller.address = addressTextField.text;
    worldpayapmviewcontroller.city = cityTextField.text;
    worldpayapmviewcontroller.postcode = postcodeTextField.text;
    worldpayapmviewcontroller.price = [[BasketManager sharedInstance] totalPrice];
    worldpayapmviewcontroller.customerIdentifiers = @{ @"email": @"customer.email.test123@gmail.com"};
    worldpayapmviewcontroller.orderDescription = @"Worldfood purchase";
    worldpayapmviewcontroller.countryCode = @"GB";
    worldpayapmviewcontroller.settlementCurrency = @"GBP";

    BOOL _reusable = [[Worldpay sharedInstance] reusable];

    if ([apmName isEqualToString:@"Giropay"]) {
        worldpayapmviewcontroller.currency = @"EUR";
        worldpayapmviewcontroller.swiftCode = @"ABC123";
        //for Giropay we set the token to not reusable (otherwise it won't work)
        [[Worldpay sharedInstance] setReusable:NO];
    }
    else {
        worldpayapmviewcontroller.currency = @"GBP";
        worldpayapmviewcontroller.shopperLanguageCode = @"EN";
    }
    
    __weak SampleViewController *weakSelf = self;
    __weak AppDelegate *weakDelegate  = _delegate;

    //this code blocks will be executed if the APM order is created an authorised successfully / or there is an error
    [worldpayapmviewcontroller setCreateAPMOrderBlockWithSuccess:^(NSDictionary *responseDictionary) {
        //APM Order is successful, here you can handle what to do after it (eg. clearing the basket, displaying another controller etc)
        [[BasketManager sharedInstance] clearBasket];

        //once the order has been completed, revert _reusable to whatever it was (remember we forced reusable=NO for Giropay)
        if ([apmName isEqualToString:@"Giropay"]) {
            [[Worldpay sharedInstance] setReusable:_reusable];
        }
        
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {

        NSError *error = [errors objectAtIndex:0];
        
        //user manually cancelled APM order by pressing back button on the controller
        if (error.code == 0) {
            if ([apmName isEqualToString:@"Giropay"]) {
                [[Worldpay sharedInstance] setReusable:_reusable];
            }
        }
        else {
            [weakSelf.navigationController popToViewController:[[weakSelf.navigationController viewControllers] objectAtIndex:1] animated:YES];
            [ALToastView toastInView:weakDelegate.window withText:[error localizedDescription]];
        }
        
    }];
    
    [self.navigationController pushViewController:worldpayapmviewcontroller animated:YES];
    
}

-(void)saveDeliveryAddressDefaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:addressTextField.text forKey:@"address"];
    [prefs setObject:cityTextField.text forKey:@"city"];
    [prefs setObject:postcodeTextField.text forKey:@"postcode"];
}

-(IBAction)addCardAction:(id)sender{
    
    [self saveDeliveryAddressDefaults];
    
    [addressTextField resignFirstResponder];
    [cityTextField resignFirstResponder];
    [postcodeTextField resignFirstResponder];
    
    worldpaycardviewcontroller = [[WorldpayCardViewController alloc] initWithColor:[UIColor redColor] loadingTheme:CardDetailsLoadingThemeWhite];
    
    [self.navigationController pushViewController:worldpaycardviewcontroller animated:YES];
    
    __weak SampleViewController *weakSelf = self;
    
    [worldpaycardviewcontroller setSaveButtonTapBlockWithSuccess:^(NSDictionary *responseDictionary) {
        FMDatabase *database = [DBhandler openDB];
        
        NSString *dbname = [[responseDictionary objectForKey:@"paymentMethod"] objectForKey:@"name"];
        dbname = [dbname stringByReplacingOccurrencesOfString:@"\'" withString:@"\''"];
        
        [DBhandler insert:database token:[responseDictionary objectForKey:@"token"] cardType:[[responseDictionary objectForKey:@"paymentMethod"] objectForKey:@"cardType"] name:dbname maskedCardNumber:[[responseDictionary objectForKey:@"paymentMethod"] objectForKey:@"maskedCardNumber"]];
        
        [DBhandler closeDatabase:database];
        
        weakSelf.selectedToken = [responseDictionary objectForKey:@"token"];
        
        [weakSelf createStoredCardView];
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        NSLog(@"%@", errors);
        NSLog(@"%@", [[Worldpay sharedInstance] serviceKey]);
        NSLog(@"%@", [[Worldpay sharedInstance] clientKey]);
        
        if (errors.count > 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to add card! Please check your client key!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

-(IBAction)confirmPurchaseAction:(id)sender{
    
    if(!isSelectedCard){
        [ALToastView toastInView:self.view withText:@"Please select a card to charge"];
        [confirmPurchase setUserInteractionEnabled:YES];
        return;
    }
    
    NSString *billingAddressErrorMessage = @"";
    if([addressTextField.text isEqualToString:@""]){
        billingAddressErrorMessage = [billingAddressErrorMessage stringByAppendingString:@"Please fill in address\n"];
    }
    if([cityTextField.text isEqualToString:@""]){
        billingAddressErrorMessage = [billingAddressErrorMessage stringByAppendingString:@"Please fill in city\n"];
    }
    if([postcodeTextField.text isEqualToString:@""]){
        billingAddressErrorMessage = [billingAddressErrorMessage stringByAppendingString:@"Please fill in postal code\n"];
    }
    
    if(![billingAddressErrorMessage isEqualToString:@""]){
        [ALToastView toastInView:self.view withText:billingAddressErrorMessage];
        [confirmPurchase setUserInteractionEnabled:YES];
        return;
    }

    [self saveDeliveryAddressDefaults];
    [self makePayment];
}

- (void)applePayTap {
    
    if (![[Worldpay sharedInstance] canMakePayments]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not available" message:@"Apple Pay is not available on this device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        //Create a new request using your merchant identifier
        PKPaymentRequest *request = [[Worldpay sharedInstance] createPaymentRequestWithMerchantIdentifier:@"merchant.worldpay.test"];
        
        NSMutableArray *paymentItems = [[NSMutableArray alloc] init];
        
        for (NSDictionary *item in [BasketManager sharedInstance].basket) {
            //Set the description of item
            PKPaymentSummaryItem *paymentItem = [PKPaymentSummaryItem summaryItemWithLabel:[item objectForKey:@"name"]
                                                                                    amount:[NSDecimalNumber decimalNumberWithString:[item objectForKey:@"price"]]];

            
            //Set the items to request
            [paymentItems addObject:paymentItem];
        }
        
        PKPaymentSummaryItem *totalPrice = [PKPaymentSummaryItem summaryItemWithLabel:@"Total"
                                                                               amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", [[BasketManager sharedInstance] totalPrice]]]];
        
        [paymentItems addObject:totalPrice];
        
        request.paymentSummaryItems = paymentItems;
        request.countryCode = @"GB";
        request.currencyCode = @"GBP";
        
        //Create the PKPaymentAuthorizationViewController and display it
        PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        
        viewController.delegate = self;

        
        [self presentViewController:viewController
                           animated:YES
                         completion:nil];
        
    }
}

- (void)makePayment {

    if (_delegate.threeDSEnabled) {
        ThreeDSController *threeDSController = [[ThreeDSController alloc] init];
        threeDSController.address = addressTextField.text;
        threeDSController.city = cityTextField.text;
        threeDSController.postalCode = postcodeTextField.text;
        threeDSController.token = token;
        threeDSController.name = ([[[Worldpay sharedInstance] clientKey] hasPrefix:@"T_"]) ? @"3D" : name;
        threeDSController.price = [[BasketManager sharedInstance] totalPrice];

        __weak AppDelegate *weakDelegate  = _delegate;

        
        //this code blocks will be executed if the 3DS order is created and authorised successfully / or there is an error
        [threeDSController setAuthorizeThreeDSOrderBlockWithSuccess:^(NSDictionary *responseDictionary) {
            [[BasketManager sharedInstance] clearBasket];
            SuccessPageViewController *vc = [[SuccessPageViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
            //if the token is not reusable, we remove it
            if (![[Worldpay sharedInstance] reusable]) {
                [self deleteStoredToken:_selectedToken];
            }
            
        } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
            NSError *error = [errors objectAtIndex:0];
            //error.code == 0 means: user manually cancelled 3DS authorization by pressing close button on the controller
            if (error.code != 0) {
                [self.navigationController popViewControllerAnimated:YES];
                [ALToastView toastInView:weakDelegate.window withText:[error localizedDescription]];
            }
            
        }];
        
        //if token is reusable and we are on 3DS, we need to update token before calling create order
        BOOL reusable = [[Worldpay sharedInstance] reusable];
        if (reusable) {
            [[Worldpay sharedInstance] showCVCModalWithParentView:self.view
                                                            token:token
                                                          success:^(int code, NSDictionary *responseDictionary) {
                                                              [self.navigationController pushViewController:threeDSController animated:YES];
                                                          }
                                                          beforeRequest:^{
                                                          }
                                                          error:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                              NSLog(@"%@", errors);
                                                          }];
        }
        else {
            [self.navigationController pushViewController:threeDSController animated:YES];
        }
    } else {
        
        [[Worldpay sharedInstance] showCVCModalWithParentView:self.view
                                                        token:token
                                                      success:^(int code, NSDictionary *responseDictionary) {
                                                          
                                                          
                                                          NSDictionary *requestBillingAddress = @{
                                                                                                  @"address1": addressTextField.text,
                                                                                                  @"postalCode": postcodeTextField.text,
                                                                                                  @"city": cityTextField.text,
                                                                                                  @"state": cityTextField.text
                                                                                                  };
                                                          
                                                          [self makePaymentWithToken:token
                                                                                         orderDescription:@"New Order"
                                                                                              orderAmount:@(round([[BasketManager sharedInstance] totalPrice] * 100))
                                                                                        orderCurrencyCode:@"GBP"
                                                                                      orderBillingAddress:requestBillingAddress
                                                                                                  success:^(int code, NSDictionary *responseDictionary) {
                                                                                                      /**
                                                                                                       *  At this point you should connect to your own server and complete the purchase from there.
                                                                                                       */
                                                                                                      
                                                                                                      //IMPORTANT - Always check paymentStatus, even if response comes as 200
                                                                                                      bool success = false;
                                                                                                      if ([[Worldpay sharedInstance] authorizeOnly]) {
                                                                                                          if ([[responseDictionary objectForKey:@"paymentStatus"] isEqualToString:@"AUTHORIZED"]){
                                                                                                              success = true;
                                                                                                          }
                                                                                                      }
                                                                                                      else if ([[responseDictionary objectForKey:@"paymentStatus"] isEqualToString:@"SUCCESS"]){
                                                                                                          success = true;
                                                                                                      }
                                                                                                      
                                                                                                      
                                                                                                      if (success) {
                                                                                                          SuccessPageViewController *vc = [[SuccessPageViewController alloc] init];
                                                                                                          [self.navigationController pushViewController:vc animated:YES];
                                                                                                          [[BasketManager sharedInstance] clearBasket];

                                                                                                          //if the token is not reusable, we remove it
                                                                                                          if (![[Worldpay sharedInstance] reusable]) {
                                                                                                              [self deleteStoredToken:_selectedToken];
                                                                                                          }
                                                                                                      }
                                                                                                      else {
                                                                                                          [ALToastView toastInView:self.view withText:@"Error! Check console"];

                                                                                                      }
                                                                                                    
                                                                                                  } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                                                                      [ALToastView toastInView:self.view withText:@"Error! Check console"];
                                                                                                  }];
                                                      
                                                          
                                                      }
                                                beforeRequest:^{
                                                    [ALToastView toastInView:_delegate.window withText:@"Making payment, Please wait..."];
                                                }
                                                        error:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                            NSLog(@"%@", errors);
                                                        }];
    }
}

-(IBAction)deleteItem:(id)sender {
    NSDictionary *item = [[sender layer] valueForKey:@"item"];
    
    _deleteItemAlertView = [[UIAlertView alloc] initWithTitle:@"Delete Item"
                                                        message:[NSString stringWithFormat:@"Are you sure you want to delete '%@?'", [item objectForKey:@"name"]]
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [_deleteItemAlertView.layer setValue:item forKey:@"item"];
    [_deleteItemAlertView show];
    isSelectedCard = NO;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [addressTextField resignFirstResponder];
    [cityTextField resignFirstResponder];
    [postcodeTextField resignFirstResponder];
    
    if([textField.layer.name isEqualToString:@"address"]){
        [cityTextField becomeFirstResponder];
    }else if([textField.layer.name isEqualToString:@"city"]){
        [postcodeTextField becomeFirstResponder];
    }
    
    return NO;
}

-(void)createStoredCardView {
    
    int yPos = cardsViewStartYpos;
    
    [cardsView removeFromSuperview];
    
    FMDatabase *database = [DBhandler openDB];
    cards = [DBhandler selectAllRows:database];
    [DBhandler closeDatabase:database];
    
    if (cardsView.superview) {
        [cardsView removeFromSuperview];
    }
    
    cardsView = [[UIView alloc]initWithFrame:CGRectMake(0, yPos, screenRect.size.width, 41 * cards.count)];
    cardsView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:cardsView];
    
    for(int i = 0;i<cards.count;i++){
        UIView *storedCardBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, i*40, screenRect.size.width, 40)];
        storedCardBackgroundView.backgroundColor = [UIColor whiteColor];
        [cardsView addSubview:storedCardBackgroundView];
        
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, 1)];
        line1.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
        [storedCardBackgroundView addSubview:line1];
        
        UIView *verticalLine1 = [[UIView alloc]initWithFrame:CGRectMake(45, 0, 1, 40)];
        verticalLine1.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
        [storedCardBackgroundView addSubview:verticalLine1];
        
        UIImageView *empty = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 25, 25)];
        [empty setImage:[UIImage imageNamed:@"empty.png"]];
        [storedCardBackgroundView addSubview:empty];
        
        UIImageView *cardlogo = [[UIImageView alloc]initWithFrame:CGRectMake(50, 2, 40, 35)];
        cardlogo.contentMode = UIViewContentModeScaleAspectFit;
        if([[[cards objectAtIndex:i]objectForKey:@"cardType"] containsString:@"VISA"]){
            [cardlogo setImage:[UIImage imageNamed:@"visa.png"]];
        }else if([[[cards objectAtIndex:i]objectForKey:@"cardType"] containsString:@"MAESTRO"]){
            [cardlogo setImage:[UIImage imageNamed:@"maestro.png"]];
        }else if([[[cards objectAtIndex:i]objectForKey:@"cardType"] containsString:@"MASTERCARD"]){
            [cardlogo setImage:[UIImage imageNamed:@"mastercard.png"]];
        }else if([[[cards objectAtIndex:i]objectForKey:@"cardType"] containsString:@"AMEX"]){
            [cardlogo setImage:[UIImage imageNamed:@"amex.png"]];
        } else {
            [cardlogo setImage:[UIImage imageNamed:@"default_card.png"]];
            cardlogo.frame = CGRectMake(cardlogo.frame.origin.x-1, cardlogo.frame.origin.y+3, 43, 30);
        }
        
        [storedCardBackgroundView addSubview:cardlogo];
        
        UILabel *maskedCard = [[UILabel alloc]initWithFrame:CGRectMake(95, 10, 180, 20)];
        maskedCard.text = [[cards objectAtIndex:i] objectForKey:@"maskedCardNumber"];
        maskedCard.textColor = [UIColor grayColor];
        [storedCardBackgroundView addSubview:maskedCard];
    
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 39, screenRect.size.width, 1)];
        line2.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
        [storedCardBackgroundView addSubview:line2];
        
        UIView *verticalLine2 = [[UIView alloc]initWithFrame:CGRectMake(270, 0, 1, 40)];
        verticalLine2.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
        [storedCardBackgroundView addSubview:verticalLine2];
        
        CustomGestureRecognizer *singleTap1 = [[CustomGestureRecognizer alloc] initWithTarget:self action:@selector(selectStoredCard:)];
        singleTap1.cardRow = i;
        singleTap1.containerView = storedCardBackgroundView;
        singleTap1.numberOfTapsRequired = 1;
        storedCardBackgroundView.userInteractionEnabled = YES;
        [storedCardBackgroundView addGestureRecognizer:singleTap1];
        
        UIButton *deleteStoredCard = [[UIButton alloc]initWithFrame:CGRectMake(275, 0, 40, 40)];
        deleteStoredCard.layer.name = [NSString stringWithFormat:@"%i",i];
        [deleteStoredCard setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        [deleteStoredCard addTarget:self action:@selector(deleteStoredCard:) forControlEvents:UIControlEventTouchUpInside];
        [storedCardBackgroundView addSubview:deleteStoredCard];
        
        if (_selectedToken && [[[cards objectAtIndex:i] objectForKey:@"token"] isEqualToString:_selectedToken]) {
            token = [[cards objectAtIndex:i] objectForKey:@"token"];
            name = [[cards objectAtIndex:i] objectForKey:@"name"];
            maskedCardNumber = [[cards objectAtIndex:i] objectForKey:@"maskedCardNumber"];
            cardType = [[cards objectAtIndex:i] objectForKey:@"cardType"];
            [selectedCard removeFromSuperview];
            selectedCard = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 25, 25)];
            [selectedCard setImage:[UIImage imageNamed:@"choose.png"]];
            [storedCardBackgroundView addSubview:selectedCard];
            isSelectedCard = YES;
        }
        
        yPos = yPos + 41;
    }
    
    cardsViewEndYpos = yPos;
    
    if(cardsViewEndYpos > (screenRect.size.height-60-50)){
        [scrollView setContentSize:CGSizeMake(screenRect.size.width, cardsViewEndYpos+110)];
        confirmPurchase.frame = CGRectMake(screenRect.size.width/2-80, cardsViewEndYpos+10, 160, 30);
    }
}

-(IBAction)selectStoredCard:(id)sender{
    isSelectedCard = YES;
    
    CustomGestureRecognizer *temp = sender;
    
    token = [[cards objectAtIndex:temp.cardRow] objectForKey:@"token"];
    name = [[cards objectAtIndex:temp.cardRow] objectForKey:@"name"];
    maskedCardNumber = [[cards objectAtIndex:temp.cardRow] objectForKey:@"maskedCardNumber"];
    cardType = [[cards objectAtIndex:temp.cardRow] objectForKey:@"cardType"];
    [selectedCard removeFromSuperview];
    selectedCard = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 25, 25)];
    [selectedCard setImage:[UIImage imageNamed:@"choose.png"]];
    [temp.containerView addSubview:selectedCard];
}

-(void)deleteStoredToken:(NSString *)_token {
    if (!_token) {
        return;
    }
    FMDatabase *database = [DBhandler openDB];
    [DBhandler deleteCard:database token:_token];
    isSelectedCard = NO;
    _selectedToken = @"";
    [DBhandler closeDatabase:database];
}

-(IBAction)deleteStoredCard:(id)sender{
    UIButton *temp = sender;
    _selectedRowToDelete = [temp.layer.name intValue];
    _selectedToken = @"";
    isSelectedCard = NO;
    _deleteCardAlertView = [[UIAlertView alloc] initWithTitle:@"Delete Card" message:@"Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [_deleteCardAlertView show];
}

-(void)deleteCardAtRow:(NSInteger)row {
    
    if ([_selectedToken isEqualToString:[[cards objectAtIndex:row] objectForKey:@"token"]]) {
        isSelectedCard = NO;
    }
    
    FMDatabase *database = [DBhandler openDB];
    [DBhandler deleteCard:database token:[[cards objectAtIndex:row]objectForKey:@"token"]];
    [DBhandler closeDatabase:database];
    [self createStoredCardView];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _deleteCardAlertView) {
        if (buttonIndex == 1) {
            [self deleteCardAtRow:_selectedRowToDelete];
        }
    }
    else if (alertView == _confirmAlertView) {
        SuccessPageViewController *vc = [[SuccessPageViewController alloc] init];
      
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (alertView == _quantityAlertView) {
        if (buttonIndex == 1) {
            NSString *text = [alertView textFieldAtIndex:0].text;
            long quantity = [text integerValue];
            if (quantity > 0) {
                [_selectedItem setValue:[NSNumber numberWithInteger:quantity] forKey:@"quantity"];
            }
            [[BasketManager sharedInstance] saveBasket];
          
            token = @"";
            isSelectedCard = NO;
            [scrollView removeFromSuperview];
            [self initGUI];
            [self createStoredCardView];
        }
    }
    else if (alertView == _deleteItemAlertView) {
        if (buttonIndex == 1) {
            NSDictionary *item = [[alertView layer] valueForKey:@"item"];
            [[BasketManager sharedInstance] removeItem:item];
            
            if ([[[BasketManager sharedInstance] basket] count] == 0) {
                [self.navigationController popViewControllerAnimated:YES];
                [ALToastView toastInView:_delegate.window withText:@"Basket is empty!"];
            }
            
            [scrollView removeFromSuperview];
            [self initGUI];
            [self createStoredCardView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)changeQuantityAction:(id)sender {
    _selectedItem = [[[sender view] layer] valueForKey:@"item"];
    _quantityAlertView = [[UIAlertView alloc] initWithTitle:@"Quantity" message:@"Enter new quantity" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    _quantityAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;

    [[_quantityAlertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    
    [_quantityAlertView show];
}

#pragma mark -
#pragma mark Apple Pay delegate methods

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                      didAuthorizePayment:(PKPayment *)payment
                               completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    
    #if TARGET_OS_SIMULATOR
    NSDictionary *testPaymentData = @{ @"data" : @"4444333322221111",
                                       @"signature" : @"test",
                                       @"header" : @{
                                               @"transactionId" : @"test",
                                               @"ephemeralPublicKey" : @"test",
                                               @"publicKeyHash" : @"test"
                                               }
                                       };
    
    NSError *error;
    NSData *paymentData = [NSJSONSerialization dataWithJSONObject:testPaymentData options:NSJSONWritingPrettyPrinted error: &error];
    
    #else
    NSData *paymentData = payment.token.paymentData;
    #endif
    
    
    ABMultiValueRef addressMultiValue = ABRecordCopyValue(payment.billingAddress, kABPersonAddressProperty);
    NSDictionary *addressDictionary = (__bridge_transfer NSDictionary *) ABMultiValueCopyValueAtIndex(addressMultiValue, 0);
    
    
    NSDictionary *requestBillingAddress = @{
                                            (NSString *)kABPersonAddressStreetKey: [addressDictionary objectForKey:@"Street"],
                                            (NSString *)kABPersonAddressCountryKey: [addressDictionary objectForKey:@"Country"],
                                            (NSString *)kABPersonAddressZIPKey: [addressDictionary objectForKey:@"ZIP"],
                                            (NSString *)kABPersonAddressCityKey: [addressDictionary objectForKey:@"City"]
                                            };
    
    BOOL _reusable = [[Worldpay sharedInstance] reusable];
    [[Worldpay sharedInstance] setReusable:NO];
    
    [self makePaymentWithPaymentData:paymentData
                      billingAddress:requestBillingAddress
                             success:^(int code, NSDictionary *responseDictionary) {
                                 [[BasketManager sharedInstance] clearBasket];
                                 completion(PKPaymentAuthorizationStatusSuccess);
                                 SuccessPageViewController *vc = [[SuccessPageViewController alloc] init];
                                 [self.navigationController pushViewController:vc animated:YES];
                                 [[Worldpay sharedInstance] setReusable:_reusable];
                             } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                 completion(PKPaymentAuthorizationStatusFailure);
                                 [[Worldpay sharedInstance] setReusable:_reusable];
    }];
}

-(void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Orders

- (void)makePaymentWithToken:(NSString *)paymentToken
            orderDescription:(NSString *)orderDescription
                 orderAmount:(NSNumber *)amount
           orderCurrencyCode:(NSString *)currencyCode
         orderBillingAddress:(NSDictionary *)billingAddress
                     success:(requestUpdateTokenSuccess)success
                     failure:(requestTokenFailure)failure {
  
  NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
  
  [requestParams setValue:name forKey:@"name"];
  [requestParams setValue:paymentToken forKey:@"token"];
  [requestParams setValue:orderDescription forKey:@"orderDescription"];
  [requestParams setValue:amount forKey:@"amount"];
  [requestParams setValue:currencyCode forKey:@"currencyCode"];
  [requestParams setValue:currencyCode forKey:@"settlementCurrency"];
  [requestParams setValue:billingAddress forKey:@"billingAddress"];
  
  if ([[Worldpay sharedInstance] authorizeOnly]) {
    [requestParams setValue:[NSNumber numberWithBool:YES] forKey:@"authorizeOnly"];
  }
  
  NSDictionary *additionalHeaders = @{@"Authorization": [[Worldpay sharedInstance] serviceKey]};
  
  [[Worldpay sharedInstance] makeRequestWithURL:[NSString stringWithFormat:@"%@orders", [[Worldpay sharedInstance] APIStringURL]]
         requestDictionary:requestParams
                    method:@"POST"
                   success:success
                   failure:failure
         additionalHeaders:additionalHeaders];
}

- (void)makePaymentWithPayment:(PKPayment *)payment
                       success:(requestUpdateTokenSuccess)success
                       failure:(requestTokenFailure)failure {
  ABMultiValueRef addressMultiValue = ABRecordCopyValue(payment.billingAddress, kABPersonAddressProperty);
  NSDictionary *billingAddress = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(addressMultiValue, 0);
  
  [self makePaymentWithPaymentData:payment.token.paymentData
                    billingAddress:billingAddress
                           success:success
                           failure:failure];
}

- (void)makePaymentWithPaymentData:(NSData *)paymentData
                    billingAddress:(NSDictionary *)billingAddress
                           success:(requestUpdateTokenSuccess)success
                           failure:(requestTokenFailure)failure {
    
    [[Worldpay sharedInstance] createTokenWithPaymentData:paymentData
                                                  success:^(int code, NSDictionary *responseDictionary) {
                                                      
                                                      NSString *paymentToken = [responseDictionary objectForKey:@"token"];
                                                      
                                                      NSDictionary *requestBillingAddress = @{
                                                                                              @"address1": [billingAddress objectForKey:(NSString *)kABPersonAddressStreetKey],
                                                                                              @"postalCode": [billingAddress objectForKey:(NSString *)kABPersonAddressZIPKey],
                                                                                              @"city": [billingAddress objectForKey:(NSString *)kABPersonAddressCityKey],
                                                                                              @"state": [billingAddress objectForKey:(NSString *)kABPersonAddressCityKey],
                                                                                              };
                                                      
                
                                                      [self makePaymentWithToken:paymentToken
                                                                orderDescription:@"ApplePay payment"
                                                                     orderAmount:@(round([[BasketManager sharedInstance] totalPrice] * 100))
                                                               orderCurrencyCode:@"GBP"
                                                             orderBillingAddress:requestBillingAddress
                                                                         success:success
                                                                         failure:failure];
                                                  } failure:failure];
}

@end
