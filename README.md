Worldpay iOS Library
==============

The Worldpay iOS Library makes it easy to process credit card payments direct from your app. The library allows you to create your own payment form  while at the same time making it easy to meet the security guidelines of Visa, MasterCard and Amex (called ["PCI compliance rules"](https://online.worldpay.com/support/articles/do-i-need-to-be-pci-compliant))

We also offer the opportunity to save the token that has been created in order to prevent the user from re-entering the card details.

Integration
-------------
1. Download the iOS Worldpay library

2. Open xcode create a project and drag and drop Worldpay library folder (**Worldpay/output/Worldpay**) into your Xcode project

3. A pop up window will open on xcode. Please select the following options:
    
    - Copy items into destination group's folder (if needed)
    - Create groups for any added folders
    - Add to targets. Select your project here

How To Use
-------------
1. Import the **Worldpay Library Folder** to your Project (it's inside **Worldpay/output/Worldpay**) and use

        import "Worldpay.h"

2. Set the variables to use the library (you can do this on your controller's viewDidLoad function)

        [[Worldpay sharedInstance] setClientKey:YOUR_CLIENT_KEY];

        //decide whether you want to charge this card multiple times or only once
        [[Worldpay sharedInstance] setReusable:YES];  
        
        //set validation type advanced (WorldpayValidationTypeAdvanced) or basic (WorldpayValidationTypeBasic). 
        //Basic validation just checks that is a numeric value and not empty. Advanced checks that is a valid card number.
        [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];

3. Call the following method to validate Card Details before calling the request to get token. (See Validation Error Codes below) (**This step is optional, create token and update token methods take care of handling the validation**). The result is an array of NSError elements (if no errors the array will be empty).

         NSArray *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"CARDHOLDER_NAME"
                                                                             cardNumber:@"CARD_NUMBER"
                                                                        expirationMonth:@"MM"
																		 expirationYear:@"YYYY"
                                                                                    CVC:@"CARD_CVC"];


4. To get the Token call

        [[Worldpay sharedInstance] createTokenWithNameOnCard:@"CARDHOLDER_NAME"
                                                  cardNumber:@"CARD_NUMBER"
                                             expirationMonth:@"MM"
											  expirationYear:@"YYYY"
                                                         CVC:@"CARD_CVC"
                                                     success:^(int code, NSDictionary *responseDictionary){
                                                            // save the token in the way you want. The responseDictionary will have the following structure:
                                                            // {
                                                            //        paymentMethod =     {
                                                            //              cardType = CARD_TYPE;
                                                            //              expiryMonth = MM;
                                                            //              expiryYear = YYYY;
                                                            //              maskedCardNumber = "**** **** **** XXXX";
                                                            //              name = NAME;
                                                            //              type = ObfuscatedCard;
                                                            //          };
                                                            //          reusable = 1;
                                                            //          token = "YOUR_REUSABLE_TOKEN";
                                                            // }
                                                      }
                                                     failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                            //handle errors here. The array will contain NSError objects on it.
                                                    }];

    to update the Token call

        [[Worldpay sharedInstance] reuseToken:@"YOUR_REUSABLE_TOKEN"
                                      withCVC:@"CARD_CVC"
                                      success:^(int code, NSDictionary *responseDictionary){
                                            //updated successfully
                                      }
                                      failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                            //handle error
                                      }];

    In order to ask for the CVC to the user when reusing a card, we also provide a method that displays a UIAlertView and then performs the call to reuseToken for you with the card token and the CVC

        [[Worldpay sharedInstance] showCVCModalWithParentView:self.view 
                                                        token:token
                                                      success:^(int code, NSDictionary *responseDictionary){
                                                            //updated successfully
                                                      }
                                                      error:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                            //handle error
                                                      }];                           

The WorldpayCardViewController
-------------

1. Import **Worldpay.h** and **WorldpayCardViewController.h** if you want to use the default and easy to use Card View Controller.

2. Set the variables to use the library

        [[Worldpay sharedInstance] setClientKey:YOUR_CLIENT_KEY];
        
        //decide whether you want to charge this card multiple times or only once
        [[Worldpay sharedInstance] setReusable:YES];
        
        //set validation type advanced (WorldpayValidationTypeAdvanced) or basic (WorldpayValidationTypeBasic).
        //Basic validation just checks that is a numeric value and not empty. Advanced checks that is a valid card number.
        [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];
    
3. To initialize **WorldpayCardViewController** use the following constructors 
		
		//Default theme (iOS blue theme)
        WorldpayCardViewController *worldpayCardViewController = [[WorldpayCardViewController alloc] init];
		//or
		//Custom Theme
        WorldpayCardViewController *worldpayCardViewController = [[WorldpayCardViewController alloc] initWithColor:[UIColor greenColor] loadingTheme:CardDetailsLoadingThemeWhite];
                                          

4. Push or present the worldpayCardViewController 
        
        //if you are inside a navigator controller
        [self.navigationController pushViewController:worldpayCardViewController animated:YES];

		or
		
        //if you are not inside a navigator controller
        [self presentViewController:worldpayCardViewController animated:YES completion:nil];

5. Set the "save card" button block with 

        [worldpayCardViewController setSaveButtonTapBlockWithSuccess:^(NSDictionary *responseDictionary){
                                                              // save the token,name,cardType and maskedCardNumber the way you like.
                                                              // here responseDictionary will have the same structure as the one on createTokenWithNameOnCard
                                                            } 
                                                            failure:^(NSDictionary *responseDictionary, NSError *error){
                                                              //handle the error
                                                            }
                                                            }];

Validation Methods
-------------

You can use the following methods to validate the card details without calling the create/update token methods

```
  - (BOOL)validateCardNumberBasicWithCardNumber:(NSString *)cardNumber;
  - (BOOL)validateCardNumberAdvancedWithCardNumber:(NSString *)cardNumber;
  - (BOOL)validateCardHolderNameWithName:(NSString *)holderName;
  - (BOOL)validateCardExpiryWithMonth:(int)month
                                 year:(int)year;
  - (BOOL)validateCardCVCWithNumber:(NSString *)cvc;
  - (NSArray *)validateCardDetailsWithHolderName:(NSString *)holderName
                                      cardNumber:(NSString *)cardNumber
                                 expirationMonth:(NSString *)expirationMonth
                                  expirationYear:(NSString *)expirationYear
                                             CVC:(NSString *)CVC;
  - (NSArray *)validateCardDetailsWithCVC:(NSString *)CVC
                                    token:(NSString *)token;
```

All these methods are self-explanatory and return YES (or empty array) if validation succeeds, otherwise NO (or an NSArray of NSError).
									
Error Handling
-------------

If you want to take care of checking the validation errors you can do so by iterating over the NSArray of errors and handle them by using the following error codes

| Code          | Description   |
|:-------------:|-------------|
| 1             | Card Expiry is not valid             |
| 2             | Card Number is not valid             |
| 3             | Name on card is not valid            |
| 4             | Card Verification Code is not valid  |

Example:

    for (NSError *error in errors) {
		switch (error.code) {
			case 1:
				//Card Expiry is not valid
				break;
			case 2:
				//Card Number is not valid
				break;
			case 3:
				//Name on card is not valid
				break;
			case 4:
				//Card Verification Code is not valid
				break;
			default:
				break;
		}
	}



