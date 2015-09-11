/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License for anything not specifically marked as developed by a third party.
 Apple's code excluded.
 Use at your own risk
 */

#import <UIKit/UIKit.h>
@interface UIDevice (Reachability)
+ (NSString *) localWiFiIPAddress;
+ (BOOL) networkAvailable;

+ (BOOL) activeWLAN;
+ (BOOL) activeWWAN;

+ (BOOL)isInUSA;
+(BOOL)isInChina;
+(BOOL)isInHongkong;
+(BOOL)isInTaiwan;

-(NSUInteger)getWifiBytesIn;
-(NSUInteger)getWifiBytesOut;

+(NSString *)fetchSSID;

@end