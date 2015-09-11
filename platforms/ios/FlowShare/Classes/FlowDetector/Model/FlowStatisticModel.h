//
//  FlowStatisticModel.h
//  FlowShare
//
//  Created by fu chunhui on 15/8/31.
//
//

#import <Foundation/Foundation.h>

@class FlowStatisticModel;
@protocol FlowStatisticModelDelegate <NSObject>

@optional
- (void)didGetFlowCount:(FlowStatisticModel *)model;

@end

@interface FlowStatisticModel : NSObject
+ (NSDictionary *)getDataCounters;

@property (nonatomic, readonly)NSString *wifiFlowCount;
@property (nonatomic, readonly)NSString *cellFlowCount;
@property (nonatomic, assign) id<FlowStatisticModelDelegate> delegate;

- (instancetype)initWithDelegate:(id<FlowStatisticModelDelegate>)delegate ;
- (void)stop;
- (void)start;
@end
