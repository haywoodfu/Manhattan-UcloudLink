//
//  DBHelper.m
//  colleague
//
//  Created by fu chunhui on 15-2-10.
//  Copyright (c) 2015年 HaywoodFu. All rights reserved.
//

#import "DatabaseManager.h"
#import "FMDatabase.h"
#import "FileHelper.h"

#define nCleanOldData @"cleanOldData00"

#define DB_FILENAME  @"FSInfo.sqlite"

#define kLocalSqlitePath ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:DB_FILENAME])

static DatabaseManager *dbShareInstance = nil;

@interface DatabaseManager ()
@end

@implementation DatabaseManager

+ (DatabaseManager *)shareInstance
{
    @synchronized(self)
    {
        if (dbShareInstance == nil) {
            dbShareInstance = [[DatabaseManager alloc] initWithDBPath: kLocalSqlitePath];
        }
    }
    return dbShareInstance;
}

- (id)initWithDBPath:(NSString*)path
{
    self = [super init];
    if (self) {
        [self createDatabase];
    }
    return  self;
}

/**
 *  创建数据表
 *  首先查找表是否存在，不存在则创建表；如果表存在则检查每个字段是否存在，不存在则alter table
 *  @param schema 表SQL
 *
 *  @return 返回结果
 */
- (BOOL)createTable:(NSDictionary *)schema
{
    NSString *tablename = [schema objectForKey: @"tableName"];
    NSDictionary *structure = [schema objectForKey: @"structure"];
    NSArray *option = [schema objectForKey: @"primaryKey"];
    
    NSString *tableSql = [self tableSql:tablename];
    if (tableSql.length == 0) {
        NSMutableString *sql = [NSMutableString stringWithFormat: @"CREATE TABLE IF NOT EXISTS %@", tablename];
        NSMutableArray *keyAndValues = [NSMutableArray arrayWithCapacity: 0];
        
        for (id key in structure) {
            [keyAndValues addObject: [NSString stringWithFormat: @"%@ %@", key, [structure objectForKey: key]]];
        }
        NSMutableString *optionString = [NSMutableString stringWithString: @""];
        if (option != nil) {
            [optionString appendFormat: @"PRIMARY KEY(%@)",[option componentsJoinedByString: @","]];
            [sql appendFormat: @"(%@, %@)",[keyAndValues componentsJoinedByString: @", "], optionString];
        } else {
            [sql appendFormat: @"(%@)",[keyAndValues componentsJoinedByString: @", "]];
        }
        
        return [self sqlUpdateOperation:sql arugments:nil];
    }else {
        for (id key in structure) {
            NSRange range = [tableSql rangeOfString:key];
            //sqlit不能同时更新多列，只能一列一列的修改。
            if (range.length == 0) {
                NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@",tablename,key,[structure objectForKey:key]];
                [self sqlUpdateOperation:sql arugments:nil];
            }
        }
        return YES;
    }
    
}

- (NSString *)tableSql:(NSString *)tableName {
    if (tableName.length == 0) {
        return nil;
    }
    __block NSString *tableSql = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        [db open];
        FMResultSet *rs = (FMResultSet *)[db executeQuery:[NSString stringWithFormat:@"select sql from sqlite_master where tbl_name='%@' and type='table'", tableName], nil];
        if([rs next]) {
            tableSql = [rs stringForColumn:@"sql"];
        }
        [rs close];
        [db close];
    }];
    return tableSql;
}

- (BOOL)sqlUpdateOperation:(NSString *)sql arugments:(NSArray *)argument
{
    __block BOOL result = NO;
    __block NSError *error = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        [db open];
        result = [db executeUpdate: sql withArgumentsInArray: argument];
        error = [db lastError];
        [db close];
    }];
    if (0 != error.code)
    {
        NSLog(@"sql is %@ and database errorMessage = %@",sql,[error description]);
    }
    return result;
}

- (void)cleanOldData:(NSString *)path {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL cleanFlag = [defaults boolForKey:nCleanOldData];
    if (cleanFlag) {
        return;
    }else{
        [defaults setBool:YES forKey:nCleanOldData];
        
        NSError *err = nil;
        [[NSFileManager defaultManager]removeItemAtPath:path error:&err];
        if (err) {
            NSLog(@"delete file:%@ failed",path);
        }
    }
}

- (void)createDatabase {
    NSString* dbPath = kLocalSqlitePath;
    
    //清理老数据
    [self cleanOldData:dbPath];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:dbPath]) {
        NSError *error = nil;
        NSString *orgPath = [[NSBundle mainBundle]pathForResource:DB_FILENAME ofType:nil];
        if ([[NSFileManager defaultManager]fileExistsAtPath:orgPath]) {
            [[NSFileManager defaultManager]copyItemAtPath:orgPath toPath:dbPath error:&error];
            if (error) {
                NSLog(@"copy db file fail:%@",error);
            }
        }
    }
    
    self.queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        [db open];
        NSError *error = nil;
        BOOL result = [db executeUpdate: DB_Create_Table_CoversationIndex, nil];
        if (!result) {
            error = [db lastError];
            NSLog(@"sql is %@ and database errorMessage = %@",DB_Create_Table_CoversationIndex,[error description]);
        }else {
            result = [db executeUpdate: DB_Create_Table_CoversationContent, nil];
            if (!result) {
                error = [db lastError];
                NSLog(@"sql is %@ and database errorMessage = %@",DB_Create_Table_CoversationContent,[error description]);
            }
        }
        result = [db executeUpdate: DB_Create_Table_UserInfo, nil];
        if (!result) {
            error = [db lastError];
            NSLog(@"sql is %@ and database errorMessage = %@",DB_Create_Table_UserInfo,[error description]);
        }
        [db close];
    }];
    
}

@end
