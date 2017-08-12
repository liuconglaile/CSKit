//
//  CSTableViewDelegate.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTableViewDelegate.h"

#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSKitMacro.h>
#import <CSkit/CSBaseCell.h>
#import <CSkit/CSBaseLayoutModel.h>
#else
#import "CSKitMacro.h"
#import "CSBaseCell.h"
#import "CSBaseLayoutModel.h"
#endif


@interface CSTableViewDelegate()

@property (nonatomic, copy) CSSecionNumBlock  secionNumBlock;
@property (nonatomic, copy) CSRowNumForSecionBlock  rowNumForSecionBlock;
@property (nonatomic, copy) CSRowHeightBlock  rowHeightBlock;
@property (nonatomic, copy) CSHeaderFooterHeightBlock  headerHeightBlock;
@property (nonatomic, copy) CSHeaderFooterHeightBlock  footerHeightBlock;
@property (nonatomic, copy) CSWillDisplayCellBlock  willDisplayCellBlock;
@property (nonatomic, copy) CSCellForRowBlock  cellForRowBlock;
@property (nonatomic, copy) CSTableViewAction  rowClickAction;
@property (nonatomic, copy) CSTableViewAction  cellClickAction;
@property (nonatomic, copy) CSHeaderFooterViewBlock  headerViewBlock;
@property (nonatomic, copy) CSHeaderFooterViewBlock  footerViewBlock;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) id  dataSource;

@end

@implementation CSTableViewDelegate
//{
//
//    CSSecionNumBlock secionNumBlock;
//    CSRowNumForSecionBlock rowNumForSecionBlock;
//    CSRowHeightBlock rowHeightBlock;
//    CSHeaderFooterHeightBlock headerHeightBlock;
//    CSHeaderFooterHeightBlock footerHeightBlock;
//    CSWillDisplayCellBlock willDisplayCellBlock;
//    CSCellForRowBlock cellForRowBlock;
//    CSTableViewAction rowClickAction;
//    CSTableViewAction cellClickAction;
//    CSHeaderFooterViewBlock headerViewBlock;
//    CSHeaderFooterViewBlock footerViewBlock;
//
//    UITableView *_tableView;
//    id dataSource;
//
//}
-(id)initWithTableView:(UITableView *)tableView{
    
    self = [super init];
    
    if (self) {
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return self;
    
}
- (void)setData:(id)data{
    _dataSource = data;
    
}

- (void)removeDelegate{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
}

- (id)getData{
    return _dataSource;
}
- (void)setNumberOfSections:(CSSecionNumBlock)block{
    
    _secionNumBlock=block;
}
- (void)setNumberOfRows:(CSRowNumForSecionBlock)block{
    _rowNumForSecionBlock=block;
    
    
}

- (void)setHeightForHeader:(CSHeaderFooterHeightBlock)block{
    
    _headerHeightBlock=block;
    
}
- (void)setViewForHeader:(CSHeaderFooterViewBlock)block{
    _headerViewBlock=block;
}

- (void)setHeightForFooter:(CSHeaderFooterHeightBlock)block{
    
    _footerHeightBlock=block;
    
}
- (void)setViewForFooter:(CSHeaderFooterViewBlock)block{
    
    _footerViewBlock=block;
    
}
- (void)setHeightForRow:(CSRowHeightBlock)block{
    _rowHeightBlock=block;
}
- (void)setWillDisplayCell:(CSWillDisplayCellBlock)block{
    _willDisplayCellBlock=block;
}
- (void)setCellForRow:(CSCellForRowBlock)block{
    
    _cellForRowBlock = block;
    
}
- (void)addSelectRowAction:(CSTableViewAction)action{
    
    _rowClickAction = action;
}
-(void)addCellClickAction:(CSTableViewAction)action{
    _cellClickAction = action;
    
}
#pragma mark delegate datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (_secionNumBlock) return _secionNumBlock(_dataSource);
    //下面的自定义
    return [self secionNum];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_rowNumForSecionBlock) return _rowNumForSecionBlock(_dataSource,section);
    // 下面的自定义
    return [self rowNum:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (_headerHeightBlock) return _headerHeightBlock(_dataSource,section);
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(_headerViewBlock) return _headerViewBlock(_dataSource,section);
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (_footerHeightBlock) return _footerHeightBlock(_dataSource,section);
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if(_footerViewBlock) return _footerViewBlock(_dataSource,section);
    return nil;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_rowHeightBlock)return _rowHeightBlock(_dataSource,indexPath);
    
    NSMutableArray *array = [self arrForSecion:indexPath.section];
    
    CSBaseLayoutModel *layout = array[indexPath.row];
    
    return layout.cellHeight;
    
    
    return UITableViewAutomaticDimension;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_willDisplayCellBlock) _willDisplayCellBlock(_dataSource,cell,indexPath);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_cellForRowBlock) {
        return _cellForRowBlock(tableView,_dataSource,indexPath);
    }
    //if (_cellForRowBlock) return _cellForRowBlock(tableView,_dataSource,indexPath);
    
    
    
    //下面的自定义
    NSMutableArray *array = [self arrForSecion:indexPath.section];
    CSBaseLayoutModel *layout = array[indexPath.row];
    NSString* identifier = layout.reuseIdentifier;
    
    CSNSLog(@"%@",identifier);
    CSNSLog(@"我是 cell:---->%@",[tableView dequeueReusableCellWithIdentifier:identifier]);
    
    
    CSBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    cell.layout = layout;
    
    
    if (cell.actionBlock) {
        cell.actionBlock(tableView,_dataSource,indexPath,cell);
    }
    
    
    //    [cell addActionBlock:^(id action) {
    //
    //
    //        if (_cellClickAction) _cellClickAction(tableView,_dataSource,indexPath,action);
    //    }];
    return cell;
    
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_rowClickAction)
    {
        _rowClickAction(tableView,_dataSource,indexPath,nil);
    }
    
    
    
}
-(NSInteger )secionNum{
    
    if ([_dataSource isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *dic = _dataSource;
        
        return [dic allKeys].count;
    }
    
    if ([_dataSource isKindOfClass:[NSArray class]]) {
        
        
        return  1;
    }
    
    return 1;
}
-(NSInteger )rowNum:(NSInteger)secion{
    
    if ([_dataSource isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *dic = _dataSource;
        NSMutableArray *array = dic[[NSString stringWithFormat:@"%ld",(long)secion]];
        return array.count;
    }
    
    if ([_dataSource isKindOfClass:[NSArray class]]) {
        
        
        NSMutableArray *array = _dataSource;
        return array.count;
    }
    
    return 0;
}
-(NSMutableArray *)arrForSecion:(NSInteger )secion{
    
    if ([_dataSource isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *dic = _dataSource;
        NSMutableArray *array = dic[[NSString stringWithFormat:@"%ld", (long)secion]];
        return array;
    }
    
    if ([_dataSource isKindOfClass:[NSArray class]]) {
        
        
        NSMutableArray *array = _dataSource;
        return array;
    }
    
    return nil;
    
}



@end
