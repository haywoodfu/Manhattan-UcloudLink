/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License for anything not specifically marked as developed by a third party.
 Apple's code excluded.
 Use at your own risk
 */

#import <SystemConfiguration/SystemConfiguration.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import "UIDevice-Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation UIDevice (Reachability)
SCNetworkConnectionFlags connectionFlags;

// Matt Brown's get WiFi IP addy solution
// http://mattbsoftware.blogspot.com/2009/04/how-to-get-ip-address-of-iphone-os-v221.html
+ (NSString *) localWiFiIPAddress
{
	BOOL success;
	struct ifaddrs * addrs;
	const struct ifaddrs * cursor;
	
	success = getifaddrs(&addrs) == 0;
	if (success) {
		cursor = addrs;
		while (cursor != NULL) {
			// the second test keeps from picking up the loopback address
			if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) 
			{
				NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
//				if ([name isEqualToString:@"en0"]){  // Wi-Fi adapter
                //name:pdp_ip0 for 3G
                if ([name isEqualToString:@"en0"] || [name isEqualToString:@"en1"]){   // Tencent:jiachunke 尝试多检查‘en1’的Wifi adapter 
                    NSString *ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    freeifaddrs(addrs);
                    return ip;
                }
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	return nil;
}

- (NSUInteger) getWifiBytesOut
{
	BOOL success;
	struct ifaddrs * addrs;
	const struct ifaddrs * cursor;
	
	success = getifaddrs(&addrs) == 0;
	
	NSUInteger oBytes = 0;
	if (success) {
		cursor = addrs;
		while (cursor != NULL) {
			// the second test keeps from picking up the loopback address
			if (cursor->ifa_addr->sa_family == AF_LINK && (cursor->ifa_flags & IFF_LOOPBACK) == 0) 
			{
				NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                NSString *ifname = [UIDevice activeWWAN] ? @"pdp_ip0" : @"en0";
				if ([name isEqualToString:ifname])  // cellular adapter / Wi-Fi adapter
				{
					struct if_data *if_data = (struct if_data *)cursor->ifa_data;
					
					if(if_data){
						oBytes += if_data->ifi_obytes;
					}
				}
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	
	return oBytes;
}

- (NSUInteger) getWifiBytesIn
{
	BOOL success;
	struct ifaddrs * addrs;
	const struct ifaddrs * cursor;
	
	success = getifaddrs(&addrs) == 0;
	
	NSUInteger iBytes = 0;
	
	if (success) {
		cursor = addrs;
		while (cursor != NULL) {
			// the second test keeps from picking up the loopback address
			if (cursor->ifa_addr->sa_family == AF_LINK && (cursor->ifa_flags & IFF_LOOPBACK) == 0) 
			{
				NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                NSString *ifname = [UIDevice activeWWAN] ? @"pdp_ip0" : @"en0";
				if ([name isEqualToString:ifname])  // cellular adapter / Wi-Fi adapter
				{
					struct if_data *if_data = (struct if_data *)cursor->ifa_data;
					
					if(if_data){
						iBytes += if_data->ifi_ibytes;
					}
				}
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	
	return iBytes;
}

#pragma mark Checking Connections

+ (void) pingReachabilityInternal
{
	BOOL ignoresAdHocWiFi = NO;
	struct sockaddr_in ipAddress;
	bzero(&ipAddress, sizeof(ipAddress));
	ipAddress.sin_len = sizeof(ipAddress);
	ipAddress.sin_family = AF_INET;
	ipAddress.sin_addr.s_addr = htonl(ignoresAdHocWiFi ? INADDR_ANY : IN_LINKLOCALNETNUM);
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&ipAddress);    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &connectionFlags);
    CFRelease(defaultRouteReachability);
	if (!didRetrieveFlags) 
        printf("Error. Could not recover network reachability flags\n");
}

+ (BOOL) networkAvailable
{
	[self pingReachabilityInternal];
	BOOL isReachable = ((connectionFlags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((connectionFlags & kSCNetworkFlagsConnectionRequired) != 0);
    
    BOOL nonWiFi = ((connectionFlags & kSCNetworkReachabilityFlagsTransientConnection) != 0);
	
	if (nonWiFi) {
		return YES;
	}
    
    return (isReachable && !needsConnection) ? YES : NO;
}

//下面有一些测试驱动配置，测试各种网络情况下的提示是否正确
+ (BOOL) activeWWAN  
{
	if (![self networkAvailable]) return NO;
	return ((connectionFlags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
}

+ (BOOL) activeWLAN
{  
    BOOL bRet = ([UIDevice localWiFiIPAddress] != nil);
	return bRet;
}

+ (BOOL)isInUSA{
	CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
	if (netInfo) {
		CTCarrier *carrier = [netInfo subscriberCellularProvider];
		if (carrier) {
			NSString *mcc = [carrier mobileCountryCode];
			if ([mcc isEqualToString:@"310"] || [mcc isEqualToString:@"311"]) {
				return YES;
			}
		}
	}
	
	return NO;
}

+ (BOOL)isInChina{
	CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
	if (netInfo) {
		CTCarrier *carrier = [netInfo subscriberCellularProvider];
		if (carrier) {
			NSString *mcc = [carrier mobileCountryCode];
			if ([mcc isEqualToString:@"460"]) {
				return YES;
			}
		}
	}
	
	return NO;
}

+ (BOOL)isInHongkong{
	CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
	if (netInfo) {
		CTCarrier *carrier = [netInfo subscriberCellularProvider];
		if (carrier) {
			NSString *mcc = [carrier mobileCountryCode];
			if ([mcc isEqualToString:@"454"]) {
				return YES;
			}
		}
	}
	
	return NO;
}

+ (BOOL)isInTaiwan{
	CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
	if (netInfo) {
		CTCarrier *carrier = [netInfo subscriberCellularProvider];
		if (carrier) {
			NSString *mcc = [carrier mobileCountryCode];
			if ([mcc isEqualToString:@"466"]) {
				return YES;
			}
		}
	}
	
	return NO;
}

/** Returns first non-empty SSID network info dictionary.
 *  @see CNCopyCurrentNetworkInfo */
+ (NSString *)fetchSSID
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    NSString *ssid = [SSIDInfo objectForKey:@"SSID"];
    if (ssid == nil || ![ssid isKindOfClass:[NSString class]]) {
        return nil;
    }
    return ssid;
}

+ (NSString *) getWifiMacAddress
{
    //这里做了特殊处理，api4.1以上才能取到wifi地址
    if ([[UIDevice currentDevice].systemVersion floatValue] < 4.1f)
    {
        return 0;
    }
    
    
    NSString *BSSID = nil;
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge  CFStringRef)ifnam);
        if (info && [info count]) {
            id bssid = [info valueForKey:@"BSSID"];
            if ([bssid isKindOfClass:[NSString class]]) {
                BSSID = (NSString*)bssid;
            }
            break;
        }
        info = nil;
    }
    
    if (BSSID == nil)
    {
        return 0;
    }
    
    BSSID = [BSSID stringByReplacingOccurrencesOfString:@":" withString:@""];
    long long addrLong = strtoll([BSSID UTF8String], 0, 16);
    
    //    BSSID = [NSString stringWithFormat:@"%lld", addrLong];
    return BSSID;
}

@end