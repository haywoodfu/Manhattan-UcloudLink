//
//  DatabaseModel.m
//  DiagnosisMSDK
//
//  Created by fu chunhui on 14-4-16.
//  Copyright (c) 2014年 HaywoodFu. All rights reserved.
//

#import "DatabaseModel.h"

@interface DatabaseModel () {
    BOOL _loadBeforeNetRefresh;
}
@property (nonatomic, retain)NSMutableArray *list;
@end

@implementation DatabaseModel
@synthesize isLoading = _isLoading;
@synthesize isLoadBeforeNetRefresh = _loadBeforeNetRefresh;

- (id)initWithDelegate:(id<DatabaseModelDelegate>)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
    }
    return self;
}


- (void)loadDataBeforeNetRefresh {
    _loadBeforeNetRefresh = YES;
    [self loadData];
}

- (void)loadData {
    if (_isLoading) {
//        if ([self.delegate respondsToSelector:@selector(dataBaseModelDidFailed:)]) {
//            NSError *err = [NSError errorWithDomain:modelErrorDomain code:-1 userInfo:[NSDictionary dictionaryWithObject:@"already loading" forKey:@"description"]];
//            [self.delegate dataBaseModelDidFailed:err];
//        }
        return;
    }
    _isLoading = YES;
    if (self.list == nil) {
        self.list = [NSMutableArray array];
    }
    
    if ([self.delegate respondsToSelector:@selector(dataBaseModelDidStarted:)]) {
        [self.delegate dataBaseModelDidStarted:self];
    }
    [self getDataCompletion:^(NSMutableArray *list) {
        [self.list removeAllObjects];
        [self.list addObjectsFromArray:list];
        _isLoading = NO;
        _loadBeforeNetRefresh = NO;
        if ([self.delegate respondsToSelector:@selector(dataBaseModelDidLoad:)]) {
            [self.delegate dataBaseModelDidLoad:self.list];
        }
    }];
    
    
}
//是否考虑GCD读取数据，这样还是会卡一下主界面
- (void)getDataCompletion:(void(^)(NSMutableArray * list))block {
    return;
}

- (NSMutableArray *)results {
    return self.list;
}
@end
