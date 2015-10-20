//
//  CartManager.h
//  WorldfoodWPG
//
//  Created by Bill Panagiotopoulos on 4/28/15.
//  Copyright (c) 2015 arx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasketManager : NSObject

@property (nonatomic, retain) NSMutableArray *basket;
@property (nonatomic) NSInteger popIndex;

+ (instancetype)sharedInstance;
- (void)addItem:(NSDictionary *)item;
- (void)removeItem:(NSDictionary *)item;
- (NSInteger)countItems;
- (float)totalPrice;
- (void)saveBasket;
- (NSDictionary *)popItem;
- (void)clearBasket;

@end
