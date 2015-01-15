//
//  WorldpayUtils.h
//  Worldpay
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#define UIColorFromRGBWithAlpha(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue];

#import <Foundation/Foundation.h>

@interface WorldpayUtils : NSObject

+ (void)loadFont:(NSString *)fontName;

@end
