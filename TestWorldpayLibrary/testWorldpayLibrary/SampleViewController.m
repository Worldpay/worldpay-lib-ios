//
//  SampleViewController.m
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "SampleViewController.h"
#import "Worldpay.h"
#import "WorldpayCardViewController.h"
#import "DBhandler.h"
#import "FMDatabase.h"
#import "CustomGestureRecognizer.h"
#import "ALToastView.h"
#import "SuccessPageViewController.h"

#define url https://api.worldpay.com/v1/orders

@interface SampleViewController ()
@property (nonatomic, retain) NSString *selectedToken;
@property (nonatomic, retain) UIAlertView *deleteCardAlertView;
@property (nonatomic) NSInteger selectedRowToDelete;
@end

@implementation SampleViewController{
    UITextField *textfield;
    WorldpayCardViewController *worldpaycardviewcontroller;
    CGRect screenRect;
    
    UITextField *addressTextField;
    UITextField *cityTextField;
    UITextField *postcodeTextField;
    
    UIScrollView *scrollView;
    
    UIView *cardsView;
    int cardsViewStartYpos;
    int cardsViewEndYpos;
    
    UIButton *confirmPurchase;
    
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
    
    screenRect = [[UIScreen mainScreen]bounds];

    [self createNavigationBar];
    [self initGUI];
    [self createStoredCardView];
    
    [[Worldpay sharedInstance] setClientKey:@"T_C_7612519e-09c0-4a25-aea5-8565c611f5d5"];
    [[Worldpay sharedInstance] setReusable:YES];
    [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
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
    
    UILabel *itemName = [[UILabel alloc]initWithFrame:CGRectMake(10, grayView1.frame.size.height+grayView1.frame.origin.y+20, 100, 20)];
    itemName.text = [_item objectForKey:@"name"];
    itemName.textColor = [UIColor colorWithRed:0.902 green:0 blue:0 alpha:0.8];
    [scrollView addSubview:itemName];
    
    UILabel *quantity = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width/2-20, itemName.frame.origin.y, 40, 20)];
    quantity.text = @"1";
    quantity.textAlignment = NSTextAlignmentCenter;
    quantity.textColor = [UIColor colorWithRed:0.902 green:0 blue:0 alpha:0.8];
    [scrollView addSubview:quantity];
    
    UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width-80, itemName.frame.origin.y, 80, 20)];
    price.text = [NSString stringWithFormat:@"£%@",[_item objectForKey:@"price"]];
    price.textAlignment = NSTextAlignmentCenter;
    price.textColor = [UIColor colorWithRed:0.902 green:0 blue:0 alpha:0.8];
    [scrollView addSubview:price];
    
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
    
    UIButton *addcard = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width/2-80, grayView3.frame.size.height+grayView3.frame.origin.y+10, 160, 30)];
    [addcard setTitle:@"Add card" forState:UIControlStateNormal];
    addcard.titleLabel.font = [UIFont systemFontOfSize:14];
    [addcard setBackgroundColor:[UIColor colorWithRed:0.569 green:0.569 blue:0.569 alpha:1]];
    addcard.layer.cornerRadius = 15.0f;
    [addcard addTarget:self action:@selector(addCardAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:addcard];
    
    UILabel *storedCards = [[UILabel alloc]initWithFrame:CGRectMake(10, addcard.frame.size.height+addcard.frame.origin.y+10, 100, 20)];
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
    
    confirmPurchase = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width/2-80, scrollView.frame.size.height-100, 160, 35)];
    [confirmPurchase setTitle:@"Confirm Purchase" forState:UIControlStateNormal];
    confirmPurchase.titleLabel.font = [UIFont systemFontOfSize:14];
    [confirmPurchase setBackgroundColor:[UIColor colorWithRed:0 green:0.471 blue:0.404 alpha:1]];
    confirmPurchase.layer.cornerRadius = 15.0f;
    [confirmPurchase addTarget:self action:@selector(confirmPurchaseAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:confirmPurchase];
    
    [self.view addSubview:scrollView];
    
}


-(IBAction)cancelCheckout:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)addCardAction:(id)sender{
    [addressTextField resignFirstResponder];
    [cityTextField resignFirstResponder];
    [postcodeTextField resignFirstResponder];
    
    worldpaycardviewcontroller = [[WorldpayCardViewController alloc] initWithColor:[UIColor redColor] loadingTheme:CardDetailsLoadingThemeWhite];
    
    [self.navigationController pushViewController:worldpaycardviewcontroller animated:YES];
    
    
    __weak SampleViewController *weakSelf = self;
    
    [worldpaycardviewcontroller setSaveButtonTapBlockWithSuccess:^(NSDictionary *responseDictionary) {
        FMDatabase *database = [DBhandler openDB];
        
        [DBhandler insert:database token:[responseDictionary objectForKey:@"token"] cardType:[[responseDictionary objectForKey:@"paymentMethod"] objectForKey:@"cardType"] name:[[responseDictionary objectForKey:@"paymentMethod"] objectForKey:@"name"] maskedCardNumber:[[responseDictionary objectForKey:@"paymentMethod"] objectForKey:@"maskedCardNumber"]];
        
        [DBhandler closeDatabase:database];
        
        weakSelf.selectedToken = [responseDictionary objectForKey:@"token"];
        
        [weakSelf createStoredCardView];
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        
        
        if (errors.count > 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to add card! Please check your client key!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

-(IBAction)confirmPurchaseAction:(id)sender{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:addressTextField.text forKey:@"address"];
    [prefs setObject:cityTextField.text forKey:@"city"];
    [prefs setObject:postcodeTextField.text forKey:@"postcode"];
    
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

    
    [self makePayment];
}

- (void)makePayment {

    
    [[Worldpay sharedInstance] showCVCModalWithParentView:self.view token:token success:^(int code, NSDictionary *responseDictionary) {
        /**
         *  At this point you should connect to your own server and complete the purchase from there.
         */
        
        
        [[[UIAlertView alloc] initWithTitle:@"Information"
                                    message:@"At this point you should connect to your own server and complete the purchase from there."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        NSLog(@"\n- Selected Card Details -\n> CardType: %@\n> MaskedCardNumber: %@\n> Name: %@\n> Token: %@", cardType, maskedCardNumber, name, token);
    } error:^(NSDictionary *responseDictionary, NSArray *errors) {
        NSLog(@"%@", errors);
    }];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [addressTextField resignFirstResponder];
    [cityTextField resignFirstResponder];
    [postcodeTextField resignFirstResponder];
    
    return YES;
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
        if([[[cards objectAtIndex:i]objectForKey:@"cardType"] isEqualToString:@"VISA"]){
            [cardlogo setImage:[UIImage imageNamed:@"visa.png"]];
        }else if([[[cards objectAtIndex:i]objectForKey:@"cardType"] isEqualToString:@"MAESTRO"]){
            [cardlogo setImage:[UIImage imageNamed:@"maestro.png"]];
        }else if([[[cards objectAtIndex:i]objectForKey:@"cardType"] isEqualToString:@"MASTERCARD"]){
            [cardlogo setImage:[UIImage imageNamed:@"mastercard.png"]];
        }else if([[[cards objectAtIndex:i]objectForKey:@"cardType"] isEqualToString:@"AMEX"]){
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

-(IBAction)deleteStoredCard:(id)sender{
    UIButton *temp = sender;
    _selectedRowToDelete = [temp.layer.name intValue];
    
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
        
        return;
    }
    
    SuccessPageViewController *vc = [[SuccessPageViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
