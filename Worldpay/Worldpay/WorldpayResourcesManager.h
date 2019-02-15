//
//  UIImage+Worldpay.h
//  Worldpay
//
//  Created by Vitalii Parovishnyk on 2/15/19.
//  Copyright © 2019 Worldpay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WorldpayConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface WorldpayResourcesManager : NSObject

+ (UIImage *)wp_filledImageFrom:(UIImage *)source withColor:(UIColor *)color;

+ (UIImage *)wp_imageNamed:(NSString *)name;

+ (UIImage *)wp_cardImage:(WorldpayCardType)cardType;

+ (UIImage *)wp_WorldpayPoweredImage;

@end

NS_ASSUME_NONNULL_END
