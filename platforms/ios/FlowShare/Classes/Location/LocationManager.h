//
//  LocationManager.h
//  TenantShare
//
//  Created by fu chunhui on 14-2-8.
//  Copyright (c) 2014年 HaywoodFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Locator.h"

//@protocol LocationManagerDelegate <NSObject>
//
//@optional
//- (void)didGetLocation:(CLLocation *)loc;
//- (void)locationFailed:(NSError *)error;
//
//@end

@interface LocationManager : NSObject<WGLocationDelegate>

//@property (nonatomic, assign) id<LocationManagerDelegate> delegate;

+(LocationManager*)sharedInstance;

@end
