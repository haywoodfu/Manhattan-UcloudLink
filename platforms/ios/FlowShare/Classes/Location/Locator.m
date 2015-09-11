//
//  LocationManager.m
//  TenantShare
//
//  Created by fu chunhui on 14-2-8.
//  Copyright (c) 2014年 HaywoodFu. All rights reserved.
//

#import "Locator.h"
#import <UIKit/UIKit.h>

@interface Locator ()<CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;

@end

@implementation Locator

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    self.checkinLocation = newLocation;
    //do something else
    if ([self.delegate respondsToSelector:@selector(didGetLocation:)]) {
        [self.delegate didGetLocation:self.checkinLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(locationFailed:)]) {
        [self.delegate locationFailed:error];
    }
}
- (void)getLocation {
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Starting CLLocationManager" );
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
#ifdef __IPHONE_8_0
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [self.locationManager requestWhenInUseAuthorization];
        }
#endif
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog( @"Cannot Starting CLLocationManager" );
        NSError *err = [NSError errorWithDomain:kCLErrorDomain code:1 userInfo:[NSDictionary dictionaryWithObject:@"Cannot Starting CLLocationManager,Device turn off Location Service" forKey:@"description"]];
        if ([self.delegate respondsToSelector:@selector(locationFailed:)]) {
            [self.delegate locationFailed:err];
        }
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
    }
}

- (void)dealloc {
    self.delegate = nil;
    self.locationManager = nil;
}
@end
