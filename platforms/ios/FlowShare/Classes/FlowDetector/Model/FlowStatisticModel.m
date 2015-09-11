//
//  FlowStatisticModel.m
//  FlowShare
//
//  Created by fu chunhui on 15/8/31.
//
//

#import "FlowStatisticModel.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "UIDevice-Reachability.h"

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

#define nWifiFlowCount @"nWifiFlowCount"
#define nCellFlowCount @"nCellFlowCount"

@interface FlowStatisticModel () {
    BOOL _isChecking;
}
@property (nonatomic, retain)NSTimer *checkTimer;
@end
@implementation FlowStatisticModel
@synthesize wifiFlowCount = _wifiFlowCount;
@synthesize cellFlowCount = _cellFlowCount;

- (instancetype)initWithDelegate:(id<FlowStatisticModelDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        [self startTimer];
        
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
}

- (void)start {
    [self startTimer];
}
- (void)stop {
    [self stopTimer];
}
- (void)startTimer {
    [self stopTimer];
    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkFlow) userInfo:nil repeats:YES];
    [self.checkTimer fire];
}

- (void)stopTimer {
    [self.checkTimer invalidate];
    self.checkTimer = nil;
    _isChecking = NO;
}

- (void)checkFlow {
    if (_isChecking) {
        return;
    }
    _isChecking = YES;
    NSDictionary *counters = [FlowStatisticModel getDataCounters];
    NSNumber *wifiCount = [counters objectForKey:nWifiFlowCount];
    if (wifiCount) {
        _wifiFlowCount = [FlowStatisticModel bytesToAvaiUnit:[wifiCount longLongValue] ];
    }
    
    NSNumber *cellCount = [counters objectForKey:nCellFlowCount];
    if (cellCount) {
        _cellFlowCount = [FlowStatisticModel bytesToAvaiUnit:[cellCount longLongValue] ];
    }
    _isChecking = NO;
    if ([self.delegate respondsToSelector:@selector(didGetFlowCount:)]) {
        [self.delegate didGetFlowCount:self];
    }
}

+ (NSDictionary *)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    long long WiFiSent = 0;
    long long WiFiReceived = 0;
    long long WWANSent = 0;
    long long WWANReceived = 0;
    
    NSString *name=[[NSString alloc]init];
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            
            NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) cursor->ifa_addr)->sin_addr)];
            if (addr.length > 0) {
                NSLog(@"addr:%@", addr);
            }
            
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    if (networkStatisc) {
                        WiFiSent+=networkStatisc->ifi_obytes;
                        WiFiReceived+=networkStatisc->ifi_ibytes;
                        NSLog(@"WiFiSent %lld ==%d",WiFiSent,networkStatisc->ifi_obytes);
                        NSLog(@"WiFiReceived %lld ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                        
                        NSLog(@"wifi ifi_lastchange.tv_sec ==%d",networkStatisc->ifi_lastchange.tv_sec);
                    }
                }
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    if (networkStatisc) {
                        WWANSent+=networkStatisc->ifi_obytes;
                        WWANReceived+=networkStatisc->ifi_ibytes;
                        NSLog(@"WWANSent %lld ==%d",WWANSent,networkStatisc->ifi_obytes);
                        NSLog(@"WWANReceived %lld ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                        
                        NSLog(@"wwan ifi_lastchange.tv_sec ==%d",networkStatisc->ifi_lastchange.tv_sec);
                        
                        //current ssid name
                        NSLog(@"SSID: ===%@",[UIDevice fetchSSID]);
                    }
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithLongLong:WiFiSent + WiFiReceived],
            nWifiFlowCount,
            [NSNumber numberWithLongLong:WWANSent + WWANReceived],
            nCellFlowCount,
            nil];
}

+ (NSString *)bytesToAvaiUnit:(long long)bytes
{
    if(bytes < 1024)     // B
    {
        return [NSString stringWithFormat:@"%lldB", bytes];
    }
    else if(bytes >= 1024 && bytes < 1024 * 1024) // KB
    {
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)   // MB
    {
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}
@end
