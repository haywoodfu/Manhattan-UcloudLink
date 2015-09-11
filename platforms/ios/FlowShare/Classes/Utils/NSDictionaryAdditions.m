//
//  NSDictionaryAdditions.m
//  WGFrameworkDemo
//
//  Created by fu chunhui on 13-11-26.
//  Copyright (c) 2013年 tencent.com. All rights reserved.
//

#import "NSDictionaryAdditions.h"

@implementation NSDictionary (AdditionCategory)

- (NSString *)stringForKey:(id)key {
    id t = [self objectForKey:key];
    if (![t isKindOfClass:[NSString class]]) {
        return @"";
    }else if (((NSString *)t).length == 0){
        return @"";
    }else {
        return t;
    }
}
- (NSData *)dataForKey:(id)key {
    id t = [self objectForKey:key];
    if (![t isKindOfClass:[NSData class]]) {
        return nil;
    }else {
        return t;
    }
}
- (NSNumber *)numberForKey:(id)key {
    id t = [self objectForKey:key];
    if (![t isKindOfClass:[NSNumber class]]) {
        return nil;
    }else {
        return t;
    }
}
@end
