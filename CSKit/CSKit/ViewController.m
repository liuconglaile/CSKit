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
#import "CSKitHeader.h"

#import "CSNetwork.h"
#import "CSURLSession.h"

@interface ViewController ()

@property (nonatomic, strong) UITableView* tableView;

@end

#define kCellIdentifier @"CSRootCell"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //创建请求
    NSURL * url = [NSURL URLWithString:@"http://ykp.api.newedge.cc/App/Bar/getBarList"];
    CSURLSession * request = [[CSURLSession alloc] initWithURL:url];
    //忽略Cookies
    [request setUseCookies:NO];
    //添加表单数据
    [request addFormData:@"20" forKey:@"num"];
    [request addFormData:@"1" forKey:@"page"];
    [request addFormData:@"23.013876" forKey:@"lat"];
    [request addFormData:@"113.356125" forKey:@"lng"];
    [request addFormData:@"广州市" forKey:@"city"];
    // 开始表单请求
    //[request startRequest];
    [request startFormRequest];
    if([request getStatusCode] == 200){
        NSLog(@"%@",[request getResponseDataString]);
    }
    else {
        NSLog(@"Error:%@",[request getError].domain);
    }
    
    
    [self initTableView];
    [self initData];
    
    
    
    NSDictionary *params = @{ @"key":@"201cd6c770038",
                              @"card":@"6228480402564890018" };
    
    
    NSString* api = @"http://apicloud.mob.com/appstore/bank/card/query";
    CSNetwork.defaultManager.GET(api,params,^(id response, BOOL isSuccess, NSInteger errorCode) {
        NSLog(@"\nresponse:%@\nerrorCode:%ld",[response dataUTF8],errorCode);
    });
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
