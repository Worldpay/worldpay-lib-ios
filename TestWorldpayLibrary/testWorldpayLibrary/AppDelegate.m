//
//  AppDelegate.m
//  testWorldpayLibrary
//
//  Created by arx on 7/16/14.
//  Copyright (c) 2014 arx. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationViewController.h"
#import "SplashScreenViewController.h"
#import "AFNetworkActivityLogger.h"
#import "AFNetworking.h"
#import "Worldpay.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    _screenRect = [[UIScreen mainScreen]bounds];
    
    SplashScreenViewController *splashScreen = [[SplashScreenViewController alloc]init];
    self.window.rootViewController = splashScreen;
    
    //self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    
    _debugMode = YES;
    [self setKeys];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
- (void)sendDebug: (NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *logEntry = [NSString stringWithFormat:@"%@ [Sample App] (%@): %@\n", dateString, [[UIDevice currentDevice] name], string];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"https://public.arx.net/~billp/ios_reports/report.asp" parameters:@{@"log": logEntry} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


- (void)setKeys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *developmentClientKey = [userDefaults valueForKey:@"developmentClientKey"];
    NSString *developmentServiceKey = [userDefaults valueForKey:@"developmentServiceKey"];
    if (!developmentClientKey) {
        developmentClientKey = @"L_C_58d93fc9-e325-45fa-8b4d-ef0c632f7c13";
        [userDefaults setValue:developmentClientKey forKey:@"developmentClientKey"];
    }
    if (!developmentServiceKey) {
        developmentServiceKey = @"L_S_60d7f849-3ff0-43fa-944e-dfd860c757ab";
        [userDefaults setValue:developmentServiceKey forKey:@"developmentServiceKey"];
    }
    
    NSString *productionClientKey = [userDefaults valueForKey:@"productionClientKey"];
    NSString *productionServiceKey = [userDefaults valueForKey:@"productionServiceKey"];
    if (!productionClientKey) {
        productionClientKey = @"L_C_57f32dce-628d-49c7-9faf-392323fe02d9";
        [userDefaults setValue:productionClientKey forKey:@"productionClientKey"];
    }
    if (!productionServiceKey) {
        productionServiceKey = @"L_S_0285ce18-8624-44d9-97aa-ffcd5fca31da";
        [userDefaults setValue:productionServiceKey forKey:@"productionServiceKey"];
    }
    
    [userDefaults synchronize];
    
    if ([[Worldpay sharedInstance] WPEnvironment] == WPEnvironmentDevelopment) {
        [[Worldpay sharedInstance] setClientKey:developmentClientKey];
        [[Worldpay sharedInstance] setServiceKey:developmentServiceKey];
    }
    else if ([[Worldpay sharedInstance] WPEnvironment] == WPEnvironmentProduction) {
        [[Worldpay sharedInstance] setClientKey:productionClientKey];
        [[Worldpay sharedInstance] setServiceKey:productionServiceKey];
    }
    
}

@end
