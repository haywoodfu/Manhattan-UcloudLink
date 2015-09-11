//
//  LocationManager.h
//  TenantShare
//
//  Created by fu chunhui on 14-2-8.
//  Copyright (c) 2014年 HaywoodFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol WGLocationDelegate <NSObject>

@optional
- (void)didGetLocation:(CLLocation *)loc;
- (void)locationFailed:(NSError *)error;
@end
@interface Locator : NSObject
@property (nonatomic, assign) id<WGLocationDelegate> delegate;
@property (nonatomic, retain) CLLocation *checkinLocation;

- (void)getLocation;
@end
