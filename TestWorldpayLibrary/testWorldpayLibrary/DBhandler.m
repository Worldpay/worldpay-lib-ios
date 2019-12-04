//
//  DBhandler.m
//  testWorldpayLibrary
//
//  Copyright (c) 2015 Worldpay. All rights reserved.
//

#import "DBhandler.h"
#import "FMDatabase.h"

@implementation DBhandler

+ (FMDatabase *)openDB {
    NSString *filePathMainBundle = [[NSBundle mainBundle] pathForResource:@"worldpay" ofType:@"sqlite"];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"worldpay.sqlite"];
    
    //[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        //NSLog(@"exists");
    }
    else{
        NSError *error;
        if ([[NSFileManager defaultManager] copyItemAtPath:filePathMainBundle toPath:filePath error:&error]) {
            //NSLog(@"File successfully copied");
        } else {
            //NSLog(@"Error description-%@ \n", [error localizedDescription]);
            //NSLog(@"Error reason-%@", [error localizedFailureReason]);
        }
    }
    
    //NSLog(@"filePath : %@",filePath);
    
    FMDatabase *database = [FMDatabase databaseWithPath:filePath];
    
    if (![database open]) {
      //  NSLog(@"db open error!");
    }
    
    return database;
}

+ (NSArray *)selectAllRows:(FMDatabase *)database{
    NSString *string = [NSString stringWithFormat:@"select * from storedcards"];
    FMResultSet *results = [database executeQuery:string];
    
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    while ([results next]) {
        [rows addObject:[results resultDictionary]];
    }
    
    return rows;
}

+ (void)insert:(FMDatabase *)database token:(NSString *)token cardType:(NSString *)cardType name:(NSString *)name maskedCardNumber:(NSString *)maskedCardNumber{
  //  NSLog(@"token:%@",token);
  //  NSLog(@"cardType:%@",cardType);
  //  NSLog(@"name:%@",name);
  //  NSLog(@"maskedCardNumber:%@",maskedCardNumber);
    
    NSString *string = [NSString stringWithFormat:@"insert into storedcards (token,cardType,name,maskedCardNumber) values('%@','%@','%@','%@')",token,cardType,name,maskedCardNumber];
    
    BOOL y = [database executeUpdate:string];
    if (!y) {
        NSLog(@"insert failed!!");
    }
    else {
        NSLog(@"insert succeeded!!");
    }
    
}

+ (void)deleteCard:(FMDatabase *)database token:(NSString *)token{
    NSString *string = [NSString stringWithFormat:@"delete from storedcards where token='%@'",token];
    BOOL y = [database executeUpdate:string];
    if (!y) {
        NSLog(@"delete failed!!");
    }
    else {
        NSLog(@"delete succeeded!!");
    }
}

+ (void)deleteAllCards:(FMDatabase *)database {
    NSString *string = @"delete from storedcards";
    BOOL y = [database executeUpdate:string];
    if (!y) {
      NSLog(@"delete failed!!");
    }
    else {
      NSLog(@"delete succeeded!!");
    }
}

+ (void)closeDatabase: (FMDatabase *)database {
    [database close];
}

@end
