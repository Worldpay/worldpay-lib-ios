//
//  MainPageViewController.m
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "MainPageViewController.h"
#import "SampleViewController.h"
#import "SettingsTableViewController.h"
#import "BasketManager.h"
#import "ALToastView.h"
#import <AddressBook/AddressBook.h>

@interface MainPageViewController ()
@property (nonatomic, retain) UIButton *basketButton;
@end

@implementation MainPageViewController{
    UITableView *tableView;
    UIScrollView *scrollView;
    
    NSArray *foodArray;
    NSArray *foodDescriptionArray;
    NSArray *foodPriceArray;
    NSArray *foodFlagsArray;
    NSArray *foodPicturesArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createNavigationBar];
    [self setArrays];
    [self createTableView];
    [self createScrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)createNavigationBar {
    UIView *navigationBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen]bounds].size.width, 40)];
    navigationBarView.backgroundColor = [UIColor colorWithRed:0.941 green:0.118 blue:0.078 alpha:1];
    [self.view addSubview:navigationBarView];
    
    _basketButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 8, 25, 25)];
    [_basketButton setImage:[UIImage imageNamed:@"Basket.png"] forState:UIControlStateNormal];
    [_basketButton addTarget:self action:@selector(basketAction:) forControlEvents:UIControlEventTouchUpInside];

    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(100, 10, 117, 22)];
    [logo setImage:[UIImage imageNamed:@"logo.png"]];
    [navigationBarView addSubview:logo];
    [navigationBarView addSubview:_basketButton];
  
    UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(navigationBarView.frame.size.width-75, 10, 75, 20)];
    [settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
    [settingsButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [settingsButton addTarget:self action:@selector(settingsAction:) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [navigationBarView addSubview:settingsButton];
}

- (void)setArrays {
    foodArray = @[@"Roast Beef",
                  @"Paella",
                  @"Moussaka"];
    foodDescriptionArray = @[@"Rare roast topside with Marmite & sweet onion gravy.",
                             @"Chicken, seafood, vegetables, rice.",
                             @"Classic baked dish of layered ground beef. Served with house salad."];
    foodPriceArray = @[@"1.99",
                       @"2.99",
                       @"3.99"];
    
    foodFlagsArray = @[@"uk.png",
                       @"spain.png",
                       @"greece.png"];
    
    foodPicturesArray = @[@"roastbeef.jpg",
                          @"paella.jpg",
                          @"moussaka.jpg"];
}

- (void)createScrollView {
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 60, [[UIScreen mainScreen]bounds].size.width, 125)];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    
    for (int i = 0; i < foodPicturesArray.count; ++i) {
        UIImageView *picture = [[UIImageView alloc]initWithFrame:CGRectMake(i*320, 0, [[UIScreen mainScreen]bounds].size.width, 125)];
        [picture setImage:[UIImage imageNamed:[foodPicturesArray objectAtIndex:i]]];
        [scrollView addSubview:picture];
    }
    scrollView.contentSize = CGSizeMake(320*foodPicturesArray.count, 125);
}

- (void)createTableView {
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60+125, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor lightGrayColor];
    tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
       
    [self.view addSubview:tableView];

}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *item = [@{
                                   @"name":[foodArray objectAtIndex:indexPath.row],
                                   @"price":[foodPriceArray objectAtIndex:indexPath.row],
                                   @"quantity": [NSNumber numberWithInteger:1]
                                   } mutableCopy];
    
    BasketManager *basketManager = [BasketManager sharedInstance];
    [basketManager addItem:item];
    
    [ALToastView toastInView:self.view withText:[NSString stringWithFormat:@"Added to basket! (Total: %lu items)", (unsigned long)[[BasketManager sharedInstance] countItems]]];
    
    [UIView animateWithDuration:0.1 animations:^{
        self->_basketButton.transform = CGAffineTransformMakeRotation(M_PI_4/2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self->_basketButton.transform = CGAffineTransformMakeRotation(-M_PI_4/2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self->_basketButton.transform = CGAffineTransformMakeRotation(0);
            }];
        }];
    }];    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return foodArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    UIView *cellView;
    
    if (cell == nil) {
        cellView = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 90)];
        cellView.backgroundColor = [UIColor clearColor];
        cellView.tag = 11111;
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else{
        cellView = (UIView *)[cell viewWithTag:11111];
    }
    
    cellView.backgroundColor = [UIColor clearColor];
    [self createCellView:indexPath.row cellView:cellView];
    [cell addSubview:cellView];
    
    return cell;
}

- (void)createCellView:(long)indexPathRow cellView:(UIView *)cv {
    UIImageView *flag = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 27, 22)];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(50, 15, 150, 20)];
    UILabel *description = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 240, 60)];
    UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(250, 20, 60, 30)];
    UIButton *order = [[UIButton alloc]initWithFrame:CGRectMake(250, 50, 60, 20)];
    
    [flag setImage:[UIImage imageNamed:[foodFlagsArray objectAtIndex:indexPathRow]]];
    title.text = [foodArray objectAtIndex:indexPathRow];
    title.textColor = [UIColor colorWithRed:0.941 green:0.118 blue:0.078 alpha:1];
    description.text = [foodDescriptionArray objectAtIndex:indexPathRow];
    description.font = [UIFont systemFontOfSize:12];
    description.textColor = [UIColor grayColor];
    description.lineBreakMode = NO;
    description.numberOfLines = 0;
    
    price.text = [NSString stringWithFormat:@"£%@",[foodPriceArray objectAtIndex:indexPathRow]];
    price.textAlignment = NSTextAlignmentCenter;
    price.textColor = [UIColor colorWithRed:0.941 green:0.118 blue:0.078 alpha:1];
    
    UIView *colorView = [[UIView alloc] initWithFrame:order.frame];
    colorView.backgroundColor = [UIColor colorWithRed:0 green:0.471 blue:0.404 alpha:1];
    
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [order setBackgroundImage:colorImage forState:UIControlStateNormal];
    order.layer.cornerRadius = 10.0f;
    order.clipsToBounds = YES;
    [order setTitle:@"Add" forState:UIControlStateNormal];
    order.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [cv addSubview:flag];
    [cv addSubview:title];
    [cv addSubview:description];
    [cv addSubview:order];
    [cv addSubview:price];
}

- (IBAction)settingsAction:(id)sender {
    SettingsTableViewController *settingsViewController = [[SettingsTableViewController alloc] init];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (IBAction)basketAction:(id)sender {
    if ([[[BasketManager sharedInstance] basket] count] == 0) {
        [ALToastView toastInView:self.view withText:@"Basket is empty!"];
    } else {
        SampleViewController *sampleViewController = [[SampleViewController alloc]init];
        [self.navigationController pushViewController:sampleViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
