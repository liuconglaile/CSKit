//
//  CSTestTableController.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTestTableController.h"
#import "CSTestTableLayout.h"
#import "CSTestTableModel.h"
#import "UITableView+Protocol.h"

#import "CSKit.h"
#import "CSNetworkTool+Extension.h"
#import "CSFPSLabel.h"

@interface CSTestTableController ()

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

static  NSString *CellName=@"CSTestTableCell";

@implementation CSTestTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    [self initTableView];
    [self initData];
    
    
    CSFPSLabel* titleView = [CSFPSLabel new];
    [titleView sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleView];
    
    /*
    NSString* url = @"https://api.cs.juworker.com/home/index/get/";
    CSNetworkModel* model = [[CSNetworkModel alloc] init];
    model.requestUrl = url;
    model.parameters = @{};
    model.requestType = CSNetworkMethodPOST;
    model.requestCachePolicy = CSNetworkStoreCachePolicy;
    model.attemptRequestWhenFail = YES;
    model.forbidTipErrorInfo = YES;
    
    [CSNetworkTool sendExtensionRequest:model success:^(id returnValue) {
        //CSNSLog(@"我是返回:%@",returnValue);
    } failure:^(NSError *error) {
        //CSNSLog(@"我是错误返回:%@",error);
    }];
     */
}

- (void)dealloc{
    CSNSLog(@"执行了...222222.");
    [self.tableView removeDelegate];
    [self.tableView removeAllSubviews];
    [self.tableView removeFromSuperview];
    self.tableView = nil;
  
 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[CSImageCache sharedCache].memoryCache removeAllObjects];
    [[CSImageCache sharedCache].diskCache removeAllObjectsWithBlock:^{
        
    }];
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tag = 9222;
    
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:CellName identifier:CellName];
    
    
    [self.tableView addCellClickAction:^(UITableView *tableView, id data, NSIndexPath *indexPath, id action) {
        CSNSLog(@"点击了哦........");
    }];
}

- (void)initData{
    
    self.dataSource = [NSMutableArray array];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
    NSMutableArray *dataList = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    [dataList addObjectsFromArray:dataList];
    [dataList addObjectsFromArray:dataList];
    
    for (NSDictionary *dic in dataList) {
        
        CSTestTableModel *feed =[CSTestTableModel new];
        
        feed.userName= dic[@"houseName"];
        feed.avtar   = dic[@"hotelLogo"];
        feed.content = dic[@"text"];
        feed.imageArr= dic[@"imgs"];
        feed.time    = dic[@"address"];
        
        CSTestTableLayout  *layout = [[CSTestTableLayout alloc] initWithModel:feed identifier:CellName];
        
        [self.dataSource addObject:layout];
        
    }
    [self.tableView setData:nil];
    [self.tableView setData:self.dataSource];
    [self.tableView reloadData];
    
}

@end
