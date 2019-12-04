//
//  MainPageViewController.h
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainPageViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate, UIAlertViewDelegate>

/**
 *  Function that creates a custom navigation bar with red background and logo.
 */
- (void)createNavigationBar;

/**
 *  Function that creates 4 NSArrays : foodArray , foodDescriptionArray , foodPriceArray and foodFlagsArray
    foodArray contains the food names.
    foodDescriptionArray contains the food description.
    foodPriceArray contains that prices for the food.
    foodFlagsArray contains the name of the images flags of the foods.
    foodPicturesArray contains the pictures of the foods.
 */
- (void)setArrays;

/**
 *  Function that creates UIScrollView that displays pictures of the foods.
 */
- (void)createScrollView;

/**
 *  Function that creates the UITableView that will contain each cell a specific food
 */
- (void)createTableView;

/**
 *  Function that creates the View for each food
 *
 *  @param indexPathRow passing parameter indexPath.row to indetify specific row that is created.
 *  @param cv           passing parameter the cellView to addSubViews to it.
 */
- (void)createCellView:(long)indexPathRow cellView:(UIView *)cv;

- (IBAction)settingsAction:(id)sender;
@end
