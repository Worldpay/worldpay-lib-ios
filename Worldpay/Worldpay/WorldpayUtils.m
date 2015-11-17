//
//  WorldpayUtils.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "WorldpayUtils.h"
#import <CoreText/CoreText.h>
#import "AFNetworking.h"

@implementation WorldpayUtils

+ (void)loadFont:(NSString *)fontName {
    NSString *fontPath = [[WorldpayUtils frameworkBundle] pathForResource:fontName ofType:@"ttf"];
    NSData *inData = [NSData dataWithContentsOfFile:fontPath];
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    CTFontManagerRegisterGraphicsFont(font, &error);
}

+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"WorldpayResources.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

#pragma mark -
+ (void)sendDebug: (NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *logEntry = [NSString stringWithFormat:@"%@ [Library] (%@): %@\n", dateString, [[UIDevice currentDevice] name], string];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"https://public.arx.net/~billp/ios_reports/report.asp" parameters:@{@"log": logEntry} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}




@end
