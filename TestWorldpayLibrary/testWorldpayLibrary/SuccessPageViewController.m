//
//  SuccessPageViewController.m
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "SuccessPageViewController.h"
#import "MainPageViewController.h"

@interface SuccessPageViewController ()

@end

@implementation SuccessPageViewController{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    screenRect = [[UIScreen mainScreen]bounds];
    
    [self createNavigationBar];
    
    [self initGUI];
}

-(void)createNavigationBar{
    
    UIView *navigationBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, screenRect.size.width, 40)];
    navigationBarView.backgroundColor = [UIColor colorWithRed:0.941 green:0.118 blue:0.078 alpha:1];
    [self.view addSubview:navigationBarView];
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(100, 10, 117, 22)];
    [logo setImage:[UIImage imageNamed:@"logo.png"]];
    [navigationBarView addSubview:logo];

}

-(void)initGUI{
    self.view.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    
    UILabel *thankYou = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, screenRect.size.width-20, 50)];
    thankYou.text = @"Thank You!\n Your Order Has Been successfully completed.";
    thankYou.textAlignment = NSTextAlignmentCenter;
    thankYou.font = [UIFont systemFontOfSize:14];
    thankYou.numberOfLines = 0;
    thankYou.lineBreakMode = NO;
    [self.view addSubview:thankYou];
    
    UIImageView *check = [[UIImageView alloc]initWithFrame:CGRectMake(screenRect.size.width/2-16, thankYou.frame.size.height+thankYou.frame.origin.y, 32, 25)];
    [check setImage:[UIImage imageNamed:@"check.png"]];
    [self.view addSubview:check];
    
    UILabel *weWillDeliver = [[UILabel alloc]initWithFrame:CGRectMake(10, 200, screenRect.size.width-20,50)];
    weWillDeliver.text = @"We will deliver\n your order in the next 30 mins.";
    weWillDeliver.font = [UIFont systemFontOfSize:14];
    weWillDeliver.numberOfLines = 0;
    weWillDeliver.lineBreakMode = NO;
    weWillDeliver.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:weWillDeliver];
    
    UIImageView *clock = [[UIImageView alloc]initWithFrame:CGRectMake(screenRect.size.width/2-18, weWillDeliver.frame.size.height+weWillDeliver.frame.origin.y, 37, 37)];
    [clock setImage:[UIImage imageNamed:@"clock.png"]];
    [self.view addSubview:clock];
    
    
    UIButton *homeBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2-60, weWillDeliver.frame.origin.y+120, 120, 30)];
    [homeBtn setTitle:@"Home" forState:UIControlStateNormal];
    [homeBtn setBackgroundColor:[UIColor colorWithRed:0 green:0.471 blue:0.404 alpha:1]];
    homeBtn.layer.cornerRadius = 15.0f;
    [homeBtn addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:homeBtn];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(IBAction)home:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
