/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License for anything not specifically marked as developed by a third party.
 Apple's code excluded.
 Use at your own risk
 */

#import <UIKit/UIKit.h>
@interface UIDevice (Helper)
//判断系统是否越狱，不使用Jailbreak命名,避免被苹果监测到
+ (BOOL)isJBOS;

@end