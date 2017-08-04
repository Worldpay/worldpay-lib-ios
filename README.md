Worldpay iOS Library
==============

The Worldpay iOS Library makes it easy to process credit card & apm payments direct from your app. The library allows you to create your own payment form  while at the same time making it easy to meet the security guidelines of Visa, MasterCard and Amex (called ["PCI compliance rules"](https://online.worldpay.com/support/articles/do-i-need-to-be-pci-compliant)).
We also offer the possibility to save the token that has been created in order to prevent the user from re-entering the card details.

#### Issues
Please see our [support contact information]( https://developer.worldpay.com/jsonapi/faq/articles/how-can-i-contact-you-for-support) to raise an issue.

Integration
-------------
1. Download the iOS Worldpay library

2. Open xcode, create a project and drag and drop Worldpay library folder (**Worldpay/output/Worldpay**) into your Xcode project

3. Alternatively, you can rebuild the Worldpay library by running:
    ```
    cd Worldpay
    pod install --no-integrate
    ```
    If you do this, make sure you drag and drop the Worldpay library folder after this (as explained on the previous step).

4. A pop up window will open in xcode. Please select the following options:

    - Copy items into destination group's folder (if needed)
    - Create groups for any added folders
    - Add to targets. Select your project here

5. The Worldpay iOS Library makes use of [AFNetworking](https://github.com/AFNetworking/AFNetworking). Please make sure that you install the framework into your project by installing the podfile (pod install):

      ```
      platform :ios, '7.0'
      pod "AFNetworking", "~> 2.0"
      ```

6. **If your app is using Swift**, please make sure that you create a [Bridging Header file](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) on your app after having completed the previous steps. In order to do so,
      just create a file named yourprojectname-Bridging-Header.h with the content:

      ```
      #import "Worldpay.h"
      #import "APMController.h"
      #import "WorldpayAPMViewController.h"
      #import "ThreeDSController.h"
      #import "WorldpayCardViewController.h"
      #import "Worldpay+ApplePay.h"
      ```
      Once you have done this, please amend "Objective-C Bridging Header" on your Target Build Settings to point to the path of the file you just created.

How To Use the Library
-------------
1. Import the **Worldpay Library Folder** to your Project (it's inside **Worldpay/output/Worldpay**) and use

      ```
      import "Worldpay.h"
      ```

      You don't need to do this import if you are using **Swift**, since the Bridging Header file you created would take care of this.

2. Set the variables to use the library (you can do this on your controller's viewDidLoad function)
      ```
      /** OBJECTIVE-C **/
      [[Worldpay sharedInstance] setClientKey:YOUR_CLIENT_KEY];

      //decide whether you want to charge this card multiple times or only once
      [[Worldpay sharedInstance] setReusable:YES];

      //set validation type advanced (WorldpayValidationTypeAdvanced) or basic (WorldpayValidationTypeBasic).
      //Basic validation just checks that is a numeric value and not empty.
      //Advanced checks that is a valid card number.
      [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];

      /** SWIFT **/
      let wp: Worldpay = Worldpay.sharedInstance();
      wp.clientKey = YOUR_CLIENT_KEY;
      wp.reusable = true;
      wp.validationType = WorldpayValidationTypeAdvanced;

      ```

3. Call the following method to validate Card Details before calling the request to get token. (See Validation Error Codes below) (**This step is optional, create token and update token methods take care of handling the validation**). The result is an array of NSError elements (if no errors the array will be empty).
      ```
      /** OBJECTIVE-C **/
      NSArray *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:@"CARDHOLDER_NAME"
                                                                             cardNumber:@"CARD_NUMBER"
                                                                        expirationMonth:@"MM"
                                                                         expirationYear:@"YYYY"
                                                                                    CVC:@"CARD_CVC"];

      /** SWIFT **/
      let errors = wp.validateCardDetailsWithHolderName("CARDHOLDER_NAME", cardNumber: "CARD_NUMBER", expirationMonth: "MM", expirationYear: "YYYY", CVC: "CARD_CVC");

      ```

4. To get the Token call
      ```
      /** OBJECTIVE-C **/
      [[Worldpay sharedInstance] createTokenWithNameOnCard:@"CARDHOLDER_NAME"
                                                cardNumber:@"CARD_NUMBER"
                                           expirationMonth:@"MM"
                                            expirationYear:@"YYYY"
                                                       CVC:@"CARD_CVC"
                                                   success:^(int code, NSDictionary *responseDictionary){
                                                          // save the token in the way you want.
                                                          // The responseDictionary will look like:
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
                                                          //handle errors here.
                                                          //The array will contain NSError objects on it.
                                                  }
      ];

      /** SWIFT **/
      wp.createTokenWithNameOnCard("CARDHOLDER_NAME", cardNumber: "CARD_NUMBER", expirationMonth: "MM", expirationYear: "YYYY", CVC: "CARD_CVC", success:{(code, response) in
            // save the token in the way you want.
        }, failure: {(response) in
            // handle errors here
      });
      ```
    To update the Token call
      ```
      /** OBJECTIVE-C **/
      [[Worldpay sharedInstance] reuseToken:@"YOUR_REUSABLE_TOKEN"
                                    withCVC:@"CARD_CVC"
                                    success:^(int code, NSDictionary *responseDictionary){
                                          //updated successfully
                                    }
                                    failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                          //handle error
                                    }
      ];

      /** SWIFT **/
      wp.reuseToken("YOUR_REUSABLE_TOKEN", withCVC: "CARD_CVC", success:{(response) in
          // updated successfully
      }, failure: {(response, errors) in
          // handle errors here
      });
      ```

      In order to ask the user for the CVC when reusing a card, we also provide a method that displays a UIAlertView and then performs the call to reuseToken for you with the card token and the CVC
      ```
      /** OBJECTIVE-C **/
      [[Worldpay sharedInstance] showCVCModalWithParentView:self.view
                                                      token:@"YOUR_REUSABLE_TOKEN"
                                                    success:^(int code, NSDictionary *responseDictionary){
                                                          //updated successfully
                                                    }
                                                    beforeRequest:^(void){
                                                          //your code before the request is triggered
                                                    }
                                                    error:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                          //handle error
                                                    }
      ];

      /** SWIFT **/
      wp.showCVCModalWithParentView(self.view, token: "YOUR_REUSABLE_TOKEN",
      success:{(code, response) in
          // updated successfully
      }, beforeRequest: {() in
          //your code before the request is triggered
      },error: {(response) in
          // handle errors here
      });
      ```

The WorldpayCardViewController
-------------

The WorldpayCardViewController is a simple UIViewController that displays a card form to save cards and create tokens associated with them. You don't have to use this controller on your app if you don't want to, but in that case you will need to generate the tokens manually in the code. In order to use the controller follow these steps:

1. Import **Worldpay.h** and **WorldpayCardViewController.h** if you want to use the default and easy to use Card View Controller.

      ```
      import "Worldpay.h"
      import "WorldpayCardViewController.h"
      ```
      Again, you don't need to do these imports if you are using **Swift**, since the Bridging Header file you created would take care of this.

2. Set the variables to use the library
      ```
      [[Worldpay sharedInstance] setClientKey:YOUR_CLIENT_KEY];

      //decide whether you want to charge this card multiple times or only once
      [[Worldpay sharedInstance] setReusable:YES];

      //set validation type advanced (WorldpayValidationTypeAdvanced) or basic (WorldpayValidationTypeBasic).
      //Basic validation just checks that is a numeric value and not empty.
      //Advanced checks that is a valid card number.
      [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];

      /** SWIFT **/
      let wp: Worldpay = Worldpay.sharedInstance();
      wp.clientKey = YOUR_CLIENT_KEY;
      wp.reusable = true;
      wp.validationType = WorldpayValidationTypeAdvanced;
      ```
3. To initialize **WorldpayCardViewController** use the following constructors
      ```
      /** OBJECTIVE-C **/
      //Default theme (iOS blue theme)
      WorldpayCardViewController *worldpayCardViewController = [[WorldpayCardViewController alloc] init];
      //or
      //Custom Theme
      WorldpayCardViewController *worldpayCardViewController = [[WorldpayCardViewController alloc] initWithColor:[UIColor greenColor] loadingTheme:CardDetailsLoadingThemeWhite];

      /** SWIFT **/
      let worldpayCardViewController: WorldpayCardViewController = WorldpayCardViewController();
      //or
      let worldpayCardViewController: WorldpayCardViewController = WorldpayCardViewController(color: UIColor.greenColor(), loadingTheme: CardDetailsLoadingThemeWhite);
      ```

4. Set the "save card" button block with
      ```
      /** OBJECTIVE-C **/
      [worldpayCardViewController setSaveButtonTapBlockWithSuccess:^(NSDictionary *responseDictionary) {
          // save the token,name,cardType and maskedCardNumber the way you like.
          // here responseDictionary will have the same structure as the one on createTokenWithNameOnCard
      } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
          //handle the error
      }];

      /** SWIFT **/
      worldpayCardViewController.setSaveButtonTapBlockWithSuccess({(response) in
          // save the token,name,cardType and maskedCardNumber the way you like.
          }, failure: {(response) in
          //handle the error
      });
      ```
5. Push or present the worldpayCardViewController
      ```
      /** OBJECTIVE-C **/
      //if you are inside a navigator controller
      [self.navigationController pushViewController:worldpayCardViewController animated:YES];

      //or if you are not inside a navigator controller
      [self presentViewController:worldpayCardViewController animated:YES completion:nil];

      /** SWIFT **/
      self.presentViewController(worldpayCardViewController, animated: true, completion: nil);
      ```


APM Orders: The WorldpayAPMViewController & APMController
-------------
In addition to **Worldpay.h**, the library provides another 2 controllers:

- **WorldpayAPMViewController.h**: This is a UIViewController that displays a form that creates APM tokens, and makes use of APMController. This controller can be used as a guide for the developer to know how the process works.
- **APMController.h**: This is a controller that can be used to create an APM order, display the APM Authorisation Page on a UIWebView and handle the response.

### WorldpayAPMViewController ###
The **WorldpayAPMViewController** can be used to display a very simple form with the APM fields required to create an APM token & order. This controller will create an APM Token and will make use of the **APMController** to create the order, using the token created by itself.

1. Import **Worldpay.h** and **WorldpayAPMViewController.h**

      ```
      import "Worldpay.h"
      import "WorldpayAPMViewController.h"
      ```
      You don't need to do these imports if you are using **Swift**, since the Bridging Header file you created would take care of this.

2. Set the variables to use the library
      ```
      /** OBJECTIVE-C **/
      [[Worldpay sharedInstance] setClientKey:YOUR_CLIENT_KEY];
      [[Worldpay sharedInstance] setServiceKey:YOUR_SERVICE_KEY];

      //decide whether you want to charge this card multiple times or only once
      [[Worldpay sharedInstance] setReusable:YES];

      /** SWIFT **/
      let wp: Worldpay = Worldpay.sharedInstance();
      wp.clientKey = YOUR_CLIENT_KEY;
      wp.serviceKey = YOUR_SERVICE_KEY;
      wp.reusable = true;
      ```

3. In order to use this controller, you will need to allow arbitrary loads on your application info.plist
      ```
          <key>NSAppTransportSecurity</key>
          <dict>
              <key>NSAllowsArbitraryLoads</key>
              <true/>
          </dict>
      ```

4. To initialize **WorldpayAPMViewController** use the following constructors
      ```
      /** OBJECTIVE-C **/
      //Default theme (iOS blue theme)
      WorldpayAPMViewController *worldpayAPMViewController = [[WorldpayAPMViewController alloc] initWithAPMName:apmName];
      //or
      //Custom Theme
      WorldpayAPMViewController *worldpayAPMViewController = [[WorldpayAPMViewController alloc] initWithColor:[UIColor redColor] loadingTheme:APMDetailsLoadingThemeWhite apmName:apmName];

      /** SWIFT **/
      let worldpayAPMViewController: WorldpayAPMViewController = WorldpayAPMViewController.init(APMName: apmName);
      //OR
      let worldpayAPMViewController: WorldpayAPMViewController = WorldpayAPMViewController.init(color: UIColor.greenColor(), loadingTheme: APMDetailsLoadingThemeWhite, apmName: apmName);
      ```

5. After this, you can also initialise these elements before presenting the controller (for those properties that are not set, the form will display them as normal inputs. For those properties that have been preset, the form will display them as read-only inputs):
    ```
    //UI elements
    @property (nonatomic) UIView *customToolbar;
    @property (nonatomic) UIButton *confirmPurchaseButton;

    //Form inputs (properties)
    @property (nonatomic) NSString *apmName; //Mandatory field
    @property (nonatomic) NSString *address;
    @property (nonatomic) NSString *city;
    @property (nonatomic) NSString *postcode;
    @property (nonatomic) NSString *name;
    @property (nonatomic) NSString *countryCode;
    @property (nonatomic) NSString *currency; //For apmName ‘Giropay’, currency should be always EUR
    @property (nonatomic) NSString *settlementCurrency;
    @property (nonatomic) NSString *successUrl; //This url has to be over https, otherwise the redirect won't work
    @property (nonatomic) NSString *cancelUrl; //This url has to be over https, otherwise the redirect won't work
    @property (nonatomic) NSString *failureUrl; //This url has to be over https, otherwise the redirect won't work
    @property (nonatomic) NSString *pendingUrl; //This url has to be over https, otherwise the redirect won't work
    @property (nonatomic) NSString *shopperLanguageCode; //Only for apmName 'Paypal'
    @property (nonatomic) NSString *swiftCode; //Only for apmName 'Giropay'
    @property (nonatomic) NSString *customerOrderCode;
    @property (nonatomic) NSString *orderDescription;
    @property (nonatomic) NSDictionary *customerIdentifiers;
    ```

6. Tell the controller how to handle success/failure in case the APM order is created successfully or fails. In order to do that we use the **setCreateAPMOrderBlockWithSucess**:

    ```
    /** OBJECTIVE-C **/
    //this code blocks will be executed if the APM order is created an authorised successfully / or there is an error
    [worldpayAPMViewController setCreateAPMOrderBlockWithSuccess:^(NSDictionary *responseDictionary) {
        //APM Order is successful, here you can handle what to do after it (eg. clearing the basket, displaying another controller etc)
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        //Create Token or Create APM Order failed, here you can display an error message.
    }];

    /** SWIFT **/
    worldpayAPMViewController.setCreateAPMOrderBlockWithSuccess({(response) in
        //APM Order is successful, here you can handle what to do after it (eg. clearing the basket, displaying another controller etc)
    }, failure: {(response,errors) in
        //Create Token or Create APM Order failed, here you can display an error message.
    });

    ```

7. Last but not least, we must present the controller:

    ```
    /** OBJECTIVE-C **/
    //if you are inside a navigator controller
    [self.navigationController pushViewController:worldpayAPMViewController animated:YES];

    //if you are not inside a navigator controller
    [self presentViewController:worldpayAPMViewController animated:YES completion:nil];

    /** SWIFT **/
    self.presentViewController(worldpayAPMViewController, animated: true, completion: nil);

    ```

The **WorldpayAPMViewController** generates the token, but it uses internally **APMController** in order to create the Order and redirect to the APM Authorisation Page. However, the developer can discard using **WorldpayAPMViewController** in order to display a custom form and use only the **APMController** to create the order. We will explain this on the next subsection.

### APMController ###
The purpose of **WorldpayAPMViewController** is more documentation than using it on an actual application. If we want to create an APM order, we can use the **APMController**. This controller is a
UIWebViewDelegate controller that creates the APM Order and redirects to the APM Authorisation Page. It also lets the user handle the callback of the APM Authorisation Page. **WorldpayAPMViewController** also makes use
of this controller.

Follow these steps to use **APMController**:

1. Import **Worldpay.h** and **APMController.h**

      ```
      import "Worldpay.h"
      import "APMController.h"
      ```
      Again, you don't need to do these imports if you are using **Swift**, since the Bridging Header file you created would take care of this.

2. Set the variables to use the library
      ```
      /** OBJECTIVE-C **/
      [[Worldpay sharedInstance] setClientKey:YOUR_CLIENT_KEY];
      [[Worldpay sharedInstance] setServiceKey:YOUR_SERVICE_KEY];

      //decide whether you want to charge this card multiple times or only once
      [[Worldpay sharedInstance] setReusable:YES];

      /** SWIFT **/
      wp.clientKey = YOUR_CLIENT_KEY;
      wp.serviceKey = YOUR_SERVICE_KEY;
      wp.reusable = true;

      ```

3. In order to use this controller, you will need to allow arbitrary loads on your application info.plist
      ```
          <key>NSAppTransportSecurity</key>
          <dict>
              <key>NSAllowsArbitraryLoads</key>
              <true/>
          </dict>
      ```

4. As we don't use **WorldpayAPMViewController**, we'll need to generate an APM token ourselves. This is done by calling the createAPMTokenWithAPMName... function provided by **Worldpay.h**:
      ```
      /** OBJECTIVE-C **/
      NSDictionary *apmFields = [[NSDictionary alloc] init];
      NSString *_shopperLangCode = nil;

      //Only set Shopper language code for Paypal
      if ([_apmName isEqualToString:@"Paypal"]) {
          _shopperLangCode = @"EN"; //values here are just an example
      }
      //Only set swiftCode for Giropay
      else if ([_apmName isEqualToString:@"Giropay"]) {
          apmFields = @{@"swiftCode" : @"ABC12345" };
      }

      [[Worldpay sharedInstance] createAPMTokenWithAPMName:_apmName countryCode:@"GB" apmFields:apmFields shopperLanguageCode:_shopperLangCode
              success:^(int code, NSDictionary *responseDictionary) {
              //Once the token is created we can use the apmController with the token in responseDictionary.token
              //Now we set the fields to create the APM order

                      APMController *apmController = [[APMController alloc] init];
                      apmController.token = [responseDictionary objectForKey:@"token"];
                      apmController.address = @"Address";
                      apmController.countryCode = @"GB";
                      apmController.city = @"London";
                      apmController.currencyCode =  @"GBP"; //For apmName ‘Giropay’, currency should be always EUR
                      apmController.settlementCurrency = @"GBP";
                      apmController.postalCode = @"EC2P 2BX";
                      apmController.name = @"Name";
                      apmController.price = 50;
                      //We can optionally set apmController.customToolbar = UIView element

                      //IMPORTANT - These URLs need to be over https with a valid certificate
                      //Otherwise the redirect won't work!

                      apmController.successUrl = @"https://www.test.com/success";
                      apmController.failureUrl = @"https://www.test.com/failure";
                      apmController.cancelUrl =  @"https://www.test.com/cancel";
                      apmController.pendingUrl = @"https://www.test.com/pending";

                      apmController.customerOrderCode = @"ABC12345";
                      apmController.customerIdentifiers = @{};
                      apmController.orderDescription = @"Order description";

                      //Set the callback once the order is created
                      [apmController setAuthorizeAPMOrderBlockWithSuccess:^(NSDictionary *responseDictionary) {
                          //Order Created and authorized
                          //You can include here your custom actions
                      } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                          //Error creating or authorizing the order
                      }];

                      //Don't forget to present or push the APMController
                      [self presentViewController:apmController animated:YES completion:nil];

                   }
                   failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                      //Error creating the APM Token, we'll handle it here properly
                   }
      ];

      /** SWIFT **/

       wp.createAPMTokenWithAPMName("paypal", countryCode: "GB", apmFields: [String: String](), shopperLanguageCode: "EN", success: {(code, response) in

            let apmController: APMController = APMController();

            apmController.token = response["token"]! as? String;
            apmController.address = "address";
            apmController.countryCode = "GB";
            apmController.city = "London";
            apmController.currencyCode = "GBP";
            apmController.settlementCurrency = "GBP";
            apmController.postalCode = "EC2P 2BX";
            apmController.name = "Name";
            apmController.price = 50;

            apmController.successUrl = "https://www.test.com/success";
            apmController.failureUrl = "https://www.test.com/failure";
            apmController.cancelUrl = "https://www.test.com/cancel";
            apmController.pendingUrl = "https://www.test.com/pending";

            apmController.customerOrderCode = "ABC12345";
            apmController.customerIdentifiers = [String: String]();
            apmController.orderDescription = "description";

            apmController.setAuthorizeAPMOrderBlockWithSuccess({(response) in
                  //Order Created and authorized
                  //You can include here your custom actions
                }, failure: {(response, errors) in
                  //Error creating or authorizing the order
            })

            //Don't forget to present or push the APMController
            self.presentViewController(apmController, animated: true, completion: nil);

            }, failure: {(response, errors) in
                //Error creating the APM Token, we'll handle it here properly
        });

      ```
5. Once the token is generated successfully the callback for createAPMTokenWithAPMName will be triggered with a valid token: this is a good moment to setup your APMController to create a APM Order and display the APM Authorisation Page. It will also handle the create order result, as shown on the example above.

### ThreeDSController ###
The **ThreeDSController** is another UIWebViewDelegate controller that lets you create 3DS Orders and redirects to the 3DS Authorisation Page. It also lets the user handle the callback of the 3DS Authorisation Page.

1. Import **Worldpay.h** and **ThreeDSController.h**

      ```
      import "Worldpay.h"
      import "ThreeDSController.h"
      ```

      You don't need to do these imports if you are using **Swift**, since the Bridging Header file you created would take care of this.

2. Set the variables to use the library
      ```
      /** OBJECTIVE-C **/
      [[Worldpay sharedInstance] setClientKey:YOUR_CLIENT_KEY];
      [[Worldpay sharedInstance] setServiceKey:YOUR_SERVICE_KEY];

      //set validation type advanced (WorldpayValidationTypeAdvanced) or basic (WorldpayValidationTypeBasic).
      //Basic validation just checks that is a numeric value and not empty.
      //Advanced checks that is a valid card number.
      [[Worldpay sharedInstance] setValidationType:WorldpayValidationTypeAdvanced];

      //decide whether you want to charge this card multiple times or only once
      [[Worldpay sharedInstance] setReusable:YES];

      /** SWIFT **/
      wp.clientKey = YOUR_CLIENT_KEY;
      wp.serviceKey = YOUR_SERVICE_KEY;
      wp.reusable = true;
      wp.validationType = WorldpayValidationTypeAdvanced;
      ```

3. In order to use this controller, you will need to allow arbitrary loads on your application info.plist
      ```
          <key>NSAppTransportSecurity</key>
          <dict>
              <key>NSAllowsArbitraryLoads</key>
              <true/>
          </dict>
      ```
4. Generate an token if you don't have one stored already.
      ```

      /** OBJECTIVE-C **/
      [[Worldpay sharedInstance] createTokenWithNameOnCard:@"CARDHOLDER_NAME"
                                                cardNumber:@"CARD_NUMBER"
                                           expirationMonth:@"MM"
                                            expirationYear:@"YYYY"
                                                       CVC:@"CARD_CVC"
                                   success:^(int code, NSDictionary *responseDictionary){
                                   //Create token is successful, so we can proceed creating the 3DS order with the token we just created. If we already had a token stored,
                                   //we wouldn't need the createTokenWithNameOnCard call.
                                          ThreeDSController *threeDSController = [[ThreeDSController alloc] init];
                                          threeDSController.address = @"Adress";
                                          threeDSController.city = @"City";
                                          threeDSController.postalCode = @"Postcode";
                                          threeDSController.token = [responseDictionary objectForKey:@"token"]; // this is the Token we got on the callback on the previous step
                                          threeDSController.name = @"3D"; //name has to be "3D" for a 3DS order
                                          threeDSController.price = 39;

                                          //We can optionally set threeDSController.customToolbar = UIView element


                                          //this code blocks will be executed if the 3DS order is created and authorised successfully / or there is an error
                                          [threeDSController setAuthorizeThreeDSOrderBlockWithSuccess:^(NSDictionary *responseDictionary) {
                                              //3DS order created and authorized
                                          } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                                  //3DS Order failed
                                          }];

                                          //present or push the ThreeDSController
                                          [self presentViewController:threeDSController animated:YES completion:nil];
                                        }
                                       failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                                              //handle errors here. The array will contain NSError objects on it.
      }];

      /** SWIFT **/
      wp.createTokenWithNameOnCard("CARDHOLDER_NAME", cardNumber: "CARD_NUMBER", expirationMonth: "MM", expirationYear: "YYYY", CVC: "CARD_CVC", success: {(code, response) in

          let threeDSController: ThreeDSController = ThreeDSController();

          threeDSController.address = "Adress";
          threeDSController.city = "City";
          threeDSController.postalCode = "PostCode";
          threeDSController.token = response["token"] as? String;
          threeDSController.name = "3D";
          threeDSController.price = 39;

          threeDSController.setAuthorizeThreeDSOrderBlockWithSuccess({(response) in
              //3DS order created and authorized
              }, failure: {(response, errors) in
              //3DS Order failed
          });

          self.presentViewController(threeDSController, animated: true, completion: nil);

      }, failure: {(response, errors) in
          //handle errors here.
      });
      ```

3. Once the token is generated successfully, the callback for createTokenWithNameOnCard will be triggered. This is a good place to setup your ThreeDsController that will create the order and display the 3DS Authorisation Page (see the example above), and will also handle the create & authorize order result. If you already had a token stored, you don't need to call the createTokenWithNameOnCard function. However, if the token you created is reusable and you are trying to create a 3DS order, you need to make sure that you force to update token before pushing
the ThreeDSController, otherwise create order will fail:

      ```
      /** OBJECTIVE-C **/
      //if token is reusable and we are on 3DS, we need to force update token before calling create order
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
                                    //handle CVC error here
                                }];
      }
      else {
          [self.navigationController pushViewController:threeDSController animated:YES];
      }

      /** SWIFT **/
      //if token is reusable and we are on 3DS, we need to force update token before calling create order
      if (wp.reusable) {
          wp.showCVCModalWithParentView(self.view, token: "YOUR_REUSABLE_TOKEN",
              success:{(code, response) in
                  // updated successfully
                  self.presentViewController(threeDSController, animated: true, completion: nil);
              }, beforeRequest: {() in
                  //your code before the request is triggered
              },error: {(response) in
                  //handle CVC error here
          });
      }
      else {
          self.presentViewController(threeDSController, animated: true, completion: nil);
      }
      ```

Apple Pay
-------------

The iOS Worldpay library comes with support for Apple Pay. These are the steps to use it:

1. Import the **Worldpay ApplePay category** to your Project (it's inside **Worldpay/output/Worldpay**):
    ```
    import "Worldpay+ApplePay.h"
    ```
2. Set your app's controller delegate as PKPaymentAuthorizationViewControllerDelegate:
    ```
    @interface SampleViewController ()<PKPaymentAuthorizationViewControllerDelegate>
    ```
3. When the user taps your "Pay with ApplePay" button, check if Apple Pay is supported on the device using the canMakePayments function. Only if the device supports it, we can create a payment request and present the Apple Pay confirmation dialog:
    ```
    - (void)applePayTap {
        if (![[Worldpay sharedInstance] canMakePayments]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not available" message:@"Apple Pay is not available on this device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            //Create a PKPaymentRequest using your merchant_identifier. Please note that this is defined as a constant
            //on this example and its value must match one of the identifiers specified by the com.apple.developer.in-app-payments
            //key in the app's entitlements.
            PKPaymentRequest *request = [[Worldpay sharedInstance] createPaymentRequestWithMerchantIdentifier:merchant_identifier];
            NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithDecimal:[[_item objectForKey:@"price"] decimalValue]];
            PKPaymentSummaryItem *paymentTotal = [PKPaymentSummaryItem summaryItemWithLabel:[_item objectForKey:@"name"] amount:total];
            request.paymentSummaryItems = @[paymentTotal];
            PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
            viewController.delegate = self;

            [self presentViewController:viewController
                               animated:YES
                             completion:nil];
        }
    }
    ```
4. Last but not least, handle the response once the user has authorized the payment by defining this function inside your controller:
    ```
        - (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                              didAuthorizePayment:(PKPayment *)payment
                                       completion:(void (^)(PKPaymentAuthorizationStatus))completion {

              [[Worldpay sharedInstance] createTokenWithPaymentData:payment.token.paymentData success:^(int code, NSDictionary *responseDictionary) {
                  //Handle the Worldpay token here. At this point you should connect to your own server and complete the purchase from there.
                  completion(PKPaymentAuthorizationStatusSuccess);
              } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
                  //Handle error here.
              }];
        }
    ```

Validation Methods
-------------

You can use the following methods to validate the card details without calling the create/update token methods

```
    //Card Details validation methods
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

    //APM Details validation methods
  - (NSArray *)validateAPMDetailsWithAPMName:(NSString *)apmName
                              countryCode:(NSString *)countryCode;
  - (BOOL)validateAPMNameWithName:(NSString *)apmName;
  - (BOOL)validateCountryCodeWithCode:(NSString *)countryCode;

```

All these methods are self-explanatory and return YES (or empty array) if validation succeeds, otherwise NO (or an NSArray of NSError).

Error Handling
-------------

If you want to take care of checking the validation errors you can do so by iterating over the NSArray of errors and handle them by using the following error codes

#### Card Details validation errors ####
| Code          | Description   |
|:-------------:|-------------|
| 1             | Card Expiry is not valid             |
| 2             | Card Number is not valid             |
| 3             | Name on card is not valid            |
| 4             | Card Verification Code is not valid  |

#### APM Details validation errors ####
| Code          | Description   |
|:-------------:|-------------|
| 1             | APM Name is not valid             |
| 2             | Country Code is not valid             |

Example:
```
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
```
