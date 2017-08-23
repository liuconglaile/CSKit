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
    
//    NSString* access_token = @"12345678123456781234567812345678";//[LCAES128
//    NSString* app_id = @"88888888888888888888888888888888";
//    NSString* uid = @"10000";//
//    NSString* mobile = @"17665093500";//
//    NSString* tpl = @"10001";//
//    
//    NSDate *senddate = [NSDate date];
//    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
//    
//    NSString* tempJsonStr = [@{@"tpl":tpl,@"mobile":mobile} jsonStringEncoded];
//    CSNSLog(@"打印tempJsonStr:  %@  ----key:%@",tempJsonStr,[access_token substringToIndex:16]);
//    
//    NSString* keyValue = [access_token substringToIndex:16];
//    
//  
//    
//    NSString* data = [NSString AES128Encrypt:tempJsonStr AndKey:keyValue AndIv:keyValue];//加密
//    CSNSLog(@"打印data:  %@",data);
//    
//    
//    
//    
//    data = [data stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
//    data = [data stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
//    NSString* tempMD5 = [NSString stringWithFormat:@"%@%@%@%@%@",app_id,uid,access_token,data,timestamp];
//    CSNSLog(@"打印tempMD5:  %@",tempMD5)
//    NSString* sign = [tempMD5 md5String];
//    
//    
//    
//    
//    
//    NSString* url = @"https://pay.cs.juworker.com/Message/send";
//    
//    NSDictionary* parameters = @{@"uid":uid,
//                                 @"access_token":access_token,
//                                 @"app_id":app_id,
//                                 @"mobile":mobile,
//                                 @"tpl":tpl,
//                                 @"timestamp":timestamp,
//                                 @"sign":sign,
//                                 @"data":data};
//    
//    
//
//    
//    CSNSLog(@"我是所有参数:%@",parameters);
//    
//    
//    CSNetworkModel* model1 = [[CSNetworkModel alloc] init];
//    model1.parameters = parameters;
//    model1.requestUrl = url;
//    model1.requestType = CSNetworkMethodPOST;
//    model1.requestCachePolicy = CSNetworkIgnoreCachePolicy;
//    model1.attemptRequestWhenFail = YES;
//    model1.forbidTipErrorInfo = YES;
//    
//    [CSNetworkTool sendExtensionRequest:model1 success:^(id returnValue) {
//        CSNSLog(@"我是返回1:%@",returnValue);
//    } failure:^(NSError *error) {
//        CSNSLog(@"我是错误返回2:%@",error);
//    }];
    
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
