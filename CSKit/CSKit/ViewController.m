//
//  ViewController.m
//  CSKit
//
//  Created by 刘聪 on 2017/7/28.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "ViewController.h"
#import "CSTestTableController.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    
    
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
