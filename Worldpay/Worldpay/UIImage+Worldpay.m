//
//  UIImage+Worldpay.m
//  Worldpay
//
//  Created by Vitalii Parovishnyk on 2/15/19.
//  Copyright © 2019 Worldpay. All rights reserved.
//

#import "UIImage+Worldpay.h"

@implementation UIImage (Worldpay)

+ (UIImage *)wp_filledImageFrom:(UIImage *)source withColor:(UIColor *)color {
    
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

+ (UIImage *)wp_imageNamed:(NSString *)name {
    return [UIImage imageNamed:[@"WorldpayResources.bundle/" stringByAppendingString:name]];
}

+ (UIImage *)wp_cardImage:(WorldpayCardType)cardType {
    
    NSDictionary *cards = @{
                            @(WorldpayCardType_unknown): @"wp_ic_default_card",
                            @(WorldpayCardType_electron): @"wp_ic_electron",
                            @(WorldpayCardType_maestro): @"wp_ic_maestro",
                            @(WorldpayCardType_dankort): @"wp_ic_dankort",
                            @(WorldpayCardType_interpayment): @"wp_ic_interpayment",
                            @(WorldpayCardType_visa): @"wp_ic_visa",
                            @(WorldpayCardType_visa_checkout): @"wp_ic_visa_checkout",
                            @(WorldpayCardType_mastercard): @"wp_ic_mastercard",
                            @(WorldpayCardType_amex): @"wp_ic_amex",
                            @(WorldpayCardType_diners): @"wp_ic_diners",
                            @(WorldpayCardType_discover): @"wp_ic_discover",
                            @(WorldpayCardType_jcb): @"wp_ic_jcb",
                            @(WorldpayCardType_laser): @"wp_ic_laser",
                            @(WorldpayCardType_masterpass): @"wp_ic_masterpass",
                            };
    
    return [self wp_imageNamed:cards[@(cardType)]];
}

@end
