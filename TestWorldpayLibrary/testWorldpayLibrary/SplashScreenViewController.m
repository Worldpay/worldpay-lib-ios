
//
//  SplashScreenViewController.m
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "NavigationViewController.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

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
    
    [self initGUI];
    
    [self performSelector:@selector(pushHomePageScreen:) withObject:self afterDelay:2];
}

-(void)initGUI{
    self.view.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    
    
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(screenRect.size.width/2-49, screenRect.size.height/2-49, 98, 98)];
    [logo setImage:[UIImage imageNamed:@"loxodrome.png"]];
    [self.view addSubview:logo];
    
}

-(IBAction)pushHomePageScreen:(id)sender{
    
    NavigationViewController *navViewCon = [[NavigationViewController alloc]init];
    [self presentViewController:navViewCon animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
