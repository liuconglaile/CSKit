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
    
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:CellName identifier:CellName];
    
    
    [self.tableView addSelectRowAction:^(UITableView *tableView, id data, NSIndexPath *indexPath, id action) {
        
        
        
        
        
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
    
    [self.tableView setData:self.dataSource];
    [self.tableView reloadData];
    
}

@end
