//
//  FlowStatisticViewController.m
//  FlowShare
//
//  Created by fu chunhui on 15/9/2.
//
//

#import "FlowStatisticViewController.h"
#import "FlowStatisticModel.h"

@interface FlowStatisticViewController () <FlowStatisticModelDelegate>
@property (nonatomic, retain)FlowStatisticModel *statisticModel;
@end

@implementation FlowStatisticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.statisticModel = [[FlowStatisticModel alloc]initWithDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.statisticModel start];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.statisticModel stop];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didGetFlowCount:(FlowStatisticModel *)model {
    self.cellStatisticLbl.text = model.cellFlowCount;
    self.wifiStatisticLbl.text = model.wifiFlowCount;
}

@end
