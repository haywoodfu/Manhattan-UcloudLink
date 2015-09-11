//
//  LocationManager.m
//  TenantShare
//
//  Created by fu chunhui on 14-2-8.
//  Copyright (c) 2014年 HaywoodFu. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager ()
@property (nonatomic, retain)Locator *locator;
@end

@implementation LocationManager
static LocationManager *instance = nil;

+(LocationManager*)sharedInstance{
    @synchronized(self)
    {
        if(instance==nil){
            instance = [[LocationManager alloc] init];
        }
    }
    return instance;
}

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setLocation
{
    if (self.locator == nil) {
        self.locator = [[Locator alloc]init];
    }
    self.locator.delegate = self;
    [self.locator getLocation];
}

- (void)CleanLocationInfo
{
}
- (void)dealloc {
    self.locator = nil;
}
- (void)didGetLocation:(CLLocation *)loc {
//    CLLocationCoordinate2D coord = [loc coordinate];

    self.locator = nil;
}
- (void)locationFailed:(NSError *)error {
    self.locator = nil;
}



@end
