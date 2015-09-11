//
//  DatabaseModel.h
//  DiagnosisMSDK
//
//  Created by fu chunhui on 14-4-16.
//  Copyright (c) 2014年 HaywoodFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"

#define modelErrorDomain @"modelLoadFail"
@class DatabaseModel;

@protocol DatabaseModelDelegate <NSObject>

@optional
- (void)dataBaseModelDidLoad:(NSArray *)results;
- (void)dataBaseModelDidFailed:(NSError *)err;
- (void)dataBaseModelDidStarted:(DatabaseModel *)model;

@end

@interface DatabaseModel : NSObject

@property (nonatomic, assign) id<DatabaseModelDelegate> delegate;
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly) NSMutableArray *results;
@property (nonatomic, readonly, assign) BOOL isLoadBeforeNetRefresh;

- (id)initWithDelegate:(id<DatabaseModelDelegate>)delegate;
- (void)loadData;

//此时如果结果为空不要显示Empty cell
- (void)loadDataBeforeNetRefresh;

//给子类实现
- (void)getDataCompletion:(void(^)(NSMutableArray * list))block;
@end

