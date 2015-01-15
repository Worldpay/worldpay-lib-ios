//
//  DBhandler.h
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBhandler : NSObject

/**
 *  Function that opens DB
 *
 *  @returns database
 */
+ (FMDatabase *)openDB;

/**
 *  Function that selectes all Rows of Cards
 *
 *  @param database
 *
 *  @returns an Array of all records of Cards
 */
+ (NSArray *)selectAllRows:(FMDatabase *)database;

/**
 *  Function that closes DB
 *
 *  @param database
 */
+ (void)closeDatabase: (FMDatabase *)database;

/**
 *  Function that inserts in DB the token , the cardType, the name of the holder of the card and the maskedCardNumber
 *
 *  @param database
 *  @param token
 *  @param cardType
 *  @param name
 *  @param maskedCardNumber
 */
+ (void)insert:(FMDatabase *)database token:(NSString *)token cardType:(NSString *)cardType name:(NSString *)name maskedCardNumber:(NSString *)maskedCardNumber;

/**
 *  Function that deletes a record from the DB
 *
 *  @param database
 *  @param token    is used to indetify the specific record to be deleted
 */
+ (void)deleteCard:(FMDatabase *)database token:(NSString *)token;

@end
