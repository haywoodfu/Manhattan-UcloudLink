//
//  DBHelper.h
//  colleague
//
//  Created by fu chunhui on 15-2-10.
//  Copyright (c) 2015年 HaywoodFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "FMDatabaseQueue.h"

static NSString * const DB_Create_Table_CoversationIndex = @"create table if not exists CoversationIndex (id integer NOT NULL PRIMARY KEY AUTOINCREMENT,msgId text NOT NULL, coversationId text NOT NULL,type text,senderId text,senderType text,timestamp integer,userId text,CONSTRAINT uc_MessageIndex UNIQUE (msgId))";
static NSString * const DB_Create_Table_CoversationContent = @"create table if not exists CoversationContent (sessionId text NOT NULL,content text,contentType text,service text,serviceId text,serviceUserId text,timestamp integer, CONSTRAINT sessionId FOREIGN KEY (sessionId) REFERENCES CoversationIndex (id),CONSTRAINT uc_MessageContent UNIQUE (sessionId,content,service,serviceId))";
static NSString * const DB_Create_Table_UserInfo = @"create table if not exists UserInfo (userId text NOT NULL,userName text,platform integer,userHeaderUrl text,accessToken text,timestamp integer,PRIMARY KEY(userId))";

@interface DatabaseManager : NSObject
@property (nonatomic, retain) FMDatabaseQueue *queue;

+ (DatabaseManager *)shareInstance;

- (id)initWithDBPath:(NSString*)databasePath;

- (BOOL)createTable: (NSDictionary *)schema;

- (NSString *)tableSql:(NSString *)tableName;
@end
