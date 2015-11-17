//
//  AppDelegate.h
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) CGRect screenRect;
@property (nonatomic, retain) NSString *debugText, *apmName;
@property (nonatomic) BOOL threeDSEnabled, apmEnabled, debugMode;

- (void)sendDebug: (NSString *)string;
- (void)setKeys;
@end
