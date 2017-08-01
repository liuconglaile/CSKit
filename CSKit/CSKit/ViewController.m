//
//  ViewController.m
//  CSKit
//
//  Created by 刘聪 on 2017/7/28.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "ViewController.h"
#import "CSTestTableController.h"
#import "UITableView+Protocol.h"
#import "CSRootCell.h"
#import "CSRootModel.h"
#import "CSRootLayout.h"
#import "CSKit.h"

@interface ViewController ()

@property (nonatomic, strong) UITableView* tableView;

@end

#define kCellIdentifier @"CSRootCell"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self initTableView];
    [self initData];
    
    
}



- (void)initTableView{
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tag = 9111;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    
    [tableView registerClass:kCellIdentifier identifier:kCellIdentifier];
    
    //@weakify(self)
    [tableView addSelectRowAction:^(UITableView *tableView, id data, NSIndexPath *indexPath, id action) {
        //@strongify(self)
        if (tableView.tag == 9111) {
            if (indexPath.section == 0 && indexPath.row == 0) {
                CSTestTableController* vc = [[CSTestTableController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }];
    
    
    [tableView addCellClickAction:^(UITableView *tableView, id data, NSIndexPath *indexPath, id action) {
        CSNSLog(@"点击了哦........");
    }];
}

- (void)initData{
    
    NSMutableArray<NSDictionary *>* dataSource = [NSMutableArray array];
    
    [dataSource addObject:@{@"name":@"CSKit+UITableViewProtocol封装使用案例"}];
    [dataSource addObject:@{@"name":@"展示2"}];
    [dataSource addObject:@{@"name":@"展示3"}];
    [dataSource addObject:@{@"name":@"展示4"}];
    [dataSource addObject:@{@"name":@"展示5"}];
    [dataSource addObject:@{@"name":@"展示6"}];
    [dataSource addObject:@{@"name":@"展示7"}];
    
    NSMutableArray<CSRootLayout*>* tempData = @[].mutableCopy;
    
    for (NSDictionary *object in dataSource) {
        CSRootModel* model = [CSRootModel modelWithJSON:object];
        CSRootLayout* layout = [[CSRootLayout alloc] initWithModel:model identifier:kCellIdentifier];
        [tempData addObject:layout];
    }
    
    
    
    [self.tableView setData:tempData];
    [self.tableView reloadData];
    
}


@end
