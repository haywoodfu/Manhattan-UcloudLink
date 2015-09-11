//
//  NSDictionaryAdditions.h
//  WGFrameworkDemo
//
//  Created by fu chunhui on 13-11-26.
//  Copyright (c) 2013年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (AdditionCategory)

- (NSString *)stringForKey:(id)key;
- (NSData *)dataForKey:(id)key;
- (NSNumber *)numberForKey:(id)key;
@end
