//
//  SampleViewController.h
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FMDatabase;
@interface SampleViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSDictionary *item;



/**
 *  Function that initializes the graphical user interface
 */
- (void)initGUI;

/**
 *  Function that cancels the creation of a new card and returns to previous view controller
 *
 *  @param sender
 */
- (IBAction)cancelCheckout:(id)sender;

/**
 *  Function that creates the WorldpayCardViewController , sets the clientKey , the reusable ( if the token will be reused ) and the validation type , set the setSaveButtonTapBlock and the setSendRequestTapBlock.
 *
 *  @param sender 
 */
- (IBAction)addCardAction:(id)sender;

/**
 *  Function that validates address details.
 *
 *  @param sender 
 */
- (IBAction)confirmPurchaseAction:(id)sender;


/**
 *  Function that makes the request for the payment.
 */
- (void)makePayment;

/**
 *  Function that creates the cardView and adds it in the SampleViewController
 */
- (void)createStoredCardView;

/**
 *  Function that selects the stored card as the one that will be charged.
 *
 *  @param sender
 */
- (IBAction)selectStoredCard:(id)sender;

/**
 *  Function that deletes the already stored card in Database View and refreshes the stored cards View.
 *
 *  @param sender 
 */
- (IBAction)deleteStoredCard:(id)sender;



@end
