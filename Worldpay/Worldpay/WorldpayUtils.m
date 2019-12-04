//
//  WorldpayUtils.m
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

@import CoreText;
@import UIKit;

#import "WorldpayUtils.h"

@implementation WorldpayUtils

#pragma mark -
+ (void)sendDebug:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd-MM-yyyy HH:mm";
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    __unused NSString *logEntry = [NSString stringWithFormat:@"%@ [Library] (%@): %@\n", dateString, [UIDevice currentDevice].name, string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://public.arx.net/~billp/ios_reports/report.asp"]];
    [request setHTTPMethod:@"POST"];
    NSData *data = [[NSString stringWithFormat:@"@log=%@", logEntry] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
        
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    }];
    [dataTask resume];
}

@end
