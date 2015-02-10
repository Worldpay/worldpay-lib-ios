//
//  MainPageViewController.m
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "MainPageViewController.h"
#import "SampleViewController.h"

@interface MainPageViewController ()

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
    
    
    [self createNavigationBar];
    [self setArrays];
    [self createTableView];
    [self createScrollView];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(void)createNavigationBar{
    UIView *navigationBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen]bounds].size.width, 40)];
    navigationBarView.backgroundColor = [UIColor colorWithRed:0.941 green:0.118 blue:0.078 alpha:1];
    [self.view addSubview:navigationBarView];
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(100, 10, 117, 22)];
    [logo setImage:[UIImage imageNamed:@"logo.png"]];
    [navigationBarView addSubview:logo];
}

-(void)setArrays{
    foodArray = @[@"Roast Beef",
                  @"Paella",
                  @"Moussaka"];
    foodDescriptionArray = @[@"Rare roast topside with Marmite & sweet onion gravy.",
                             @"Chicken, seafood, vegetables, rice.",
                             @"Classic baked dish of layered ground beef, tomato and sweet onion finished with bechamel sauce. Served with house salad."];
    foodPriceArray = @[@"9.90",
                       @"11.20",
                       @"8.50"];
    
    foodFlagsArray = @[@"uk.png",
                       @"spain.png",
                       @"greece.png"];
    
    foodPicturesArray = @[@"roastbeef.jpg",
                          @"paella.jpg",
                          @"moussaka.jpg"];
}

-(void)createScrollView{
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 60, [[UIScreen mainScreen]bounds].size.width, 125)];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    
    for (int i = 0; i < foodPicturesArray.count; i++){
        UIImageView *picture = [[UIImageView alloc]initWithFrame:CGRectMake(i*320, 0, [[UIScreen mainScreen]bounds].size.width, 125)];
        [picture setImage:[UIImage imageNamed:[foodPicturesArray objectAtIndex:i]]];
        [scrollView addSubview:picture];
    }
    scrollView.contentSize = CGSizeMake(320*foodPicturesArray.count, 125);
}

-(void)createTableView{
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60+125, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height-60)];
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

-(void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = @{@"name":[foodArray objectAtIndex:indexPath.row],
                           @"price":[foodPriceArray objectAtIndex:indexPath.row]};
                           
    
    SampleViewController *sampleViewController = [[SampleViewController alloc]init];
    sampleViewController.item = item;
    [self.navigationController pushViewController:sampleViewController animated:YES];
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return foodArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    UIView *cellView;
    
    if(cell == nil){
        cellView = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 90)];
        cellView.tag = 11111;
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }else{
        cellView = (UIView *)[cell viewWithTag:11111];
    }
    
    cellView.backgroundColor = [UIColor clearColor];
    [self createCellView:indexPath.row cellView:cellView];
    [cell addSubview:cellView];
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}



-(void)createCellView:(long)indexPathRow cellView:(UIView *)cv{
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
    
    order.backgroundColor = [UIColor colorWithRed:0 green:0.471 blue:0.404 alpha:1];
    order.layer.cornerRadius = 10.0f;
    [order setTitle:@"Order" forState:UIControlStateNormal];
    order.titleLabel.font = [UIFont systemFontOfSize:12];
    
    
    [cv addSubview:flag];
    [cv addSubview:title];
    [cv addSubview:description];
    [cv addSubview:order];
    [cv addSubview:price];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
