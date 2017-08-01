//
//  ViewController.m
//  CSKit
//
//  Created by 刘聪 on 2017/7/28.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "ViewController.h"
#import "CSTestTableController.h"
#import "CSKit.h"
#import "CSNetworkTool+Extension.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    NSString* url = @"https://api.cs.juworker.com/home/index/get/";
    CSNetworkModel* model = [[CSNetworkModel alloc] init];
    model.requestUrl = @"https://www.baidu.com";
    model.parameters = @{};
    model.requestType = CSNetworkMethodPOST;
    model.requestCachePolicy = CSNetworkStoreCachePolicy;
    model.attemptRequestWhenFail = YES;
    model.forbidTipErrorInfo = YES;
    
    [CSNetworkTool sendExtensionRequest:model success:^(id returnValue) {
        CSNSLog(@"我是返回:%@",returnValue);
    } failure:^(NSError *error) {
        CSNSLog(@"我是错误返回:%@",error);
    }];
    
}

- (IBAction)showView:(id)sender {
    CSTestTableController* vc = [[CSTestTableController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
