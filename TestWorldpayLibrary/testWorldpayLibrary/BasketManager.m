//
//  CartManager.m
//  WorldfoodWPG
//
//  Created by Bill Panagiotopoulos on 4/28/15.
//  Copyright (c) 2015 arx. All rights reserved.
//

#import "BasketManager.h"

@interface BasketManager ()

@end

@implementation BasketManager

/*!
 * Sigleton method
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate;
    static BasketManager *instance;
    dispatch_once(&predicate, ^{
        instance = [[BasketManager alloc] init];
        instance.basket = [NSMutableArray array];
        
        for (NSDictionary *item in [[NSUserDefaults standardUserDefaults] objectForKey:@"basket"]) {
            [instance.basket addObject:[item mutableCopy]];
        }
        
        if (!instance.basket) {
            instance.basket = [[NSMutableArray alloc] init];
        }
    });
    
    return instance;
}

- (void)addItem:(NSMutableDictionary *)item {
    NSArray *filteredArray = [_basket filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", [item objectForKey:@"name"]]];
    
    if (filteredArray.count > 0) {
        NSDictionary *oldItem = [filteredArray objectAtIndex:0];
        
        NSInteger itemIndex = [_basket indexOfObject:oldItem];
        
        item = [oldItem mutableCopy];
        [item setValue: @([[item objectForKey:@"quantity"] integerValue] + 1) forKey:@"quantity"];
        
        [_basket replaceObjectAtIndex:itemIndex withObject:item];        
        
    } else {
        [_basket addObject:item];
    }
  
    [self saveBasket];
}

- (void)removeItem:(NSDictionary *)item {
    [_basket removeObject:item];
    [self saveBasket];
}

- (void)saveBasket {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:_basket forKey:@"basket"];
    [userDefaults synchronize];
}

- (NSInteger)countItems {
    NSInteger total = 0;
    for (NSDictionary *item in _basket) {
        total += [[item objectForKey:@"quantity"] integerValue];
    }
    
    return total;
}

- (NSDictionary *)popItem {
    if (_basket.count == 0) {
        return nil;
    }
    
    NSDictionary *thisItem = [_basket objectAtIndex:_popIndex];
    _popIndex++;
    
    return thisItem;
}

- (void)clearBasket {
  _basket = [NSMutableArray array];
  [self saveBasket];
}

- (float)totalPrice {
    float total = 0;
    for (NSDictionary *item in _basket) {
        total += [[item objectForKey:@"price"] floatValue] * [[item objectForKey:@"quantity"] integerValue];
    }
    
    return total;
}

@end
