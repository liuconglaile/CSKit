//
//  CSTableViewDelegate.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTableViewDelegate.h"
#import "CSBaseCell.h"
#import "CSBaseLayoutModel.h"

@implementation CSTableViewDelegate
{
    
    CSSecionNumBlock secionNumBlock;
    CSRowNumForSecionBlock rowNumForSecionBlock;
    CSRowHeightBlock rowHeightBlock;
    CSHeaderFooterHeightBlock headerHeightBlock;
    CSHeaderFooterHeightBlock footerHeightBlock;
    CSWillDisplayCellBlock willDisplayCellBlock;
    CSCellForRowBlock cellForRowBlock;
    CSTableViewAction rowClickAction;
    CSTableViewAction cellClickAction;
    CSHeaderFooterViewBlock headerViewBlock;
    CSHeaderFooterViewBlock footerViewBlock;
    
    UITableView *_tableView;
    id dataSource;
    
}
-(id)initWithTableView:(UITableView *)tableView{
    
    self = [super init];
    
    if (self) {
        _tableView=tableView;
        _tableView.delegate=self;
        _tableView.dataSource=self;
    }
    
    return self;
    
}
-(void)setData:(id)data{
    dataSource=data;
    
}
-(id)getData{
    
    return dataSource;
}
-(void)setNumberOfSections:(CSSecionNumBlock)block{
    
    secionNumBlock=block;
}
-(void)setNumberOfRows:(CSRowNumForSecionBlock)block{
    rowNumForSecionBlock=block;
    
    
}

-(void)setHeightForHeader:(CSHeaderFooterHeightBlock)block{
    
    headerHeightBlock=block;
    
}
-(void)setViewForHeader:(CSHeaderFooterViewBlock)block{
    headerViewBlock=block;
}
-(void)setHeightForFooter:(CSHeaderFooterHeightBlock)block{
    
    footerHeightBlock=block;
    
}
-(void)setViewForFooter:(CSHeaderFooterViewBlock)block{
    
    footerViewBlock=block;
    
}
-(void)setHeightForRow:(CSRowHeightBlock)block{
    rowHeightBlock=block;
}
-(void)setWillDisplayCell:(CSWillDisplayCellBlock)block{
    willDisplayCellBlock=block;
}
-(void)setCellForRow:(CSCellForRowBlock)block{
    
    cellForRowBlock = block;
    
}
-(void)addSelectRowAction:(CSTableViewAction)action{
    
    rowClickAction = action;
}
-(void)addCellClickAction:(CSTableViewAction)action{
    cellClickAction = action;
    
}
#pragma mark delegate datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (secionNumBlock) return secionNumBlock(dataSource);
    //下面的自定义
    return [self secionNum];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (rowNumForSecionBlock) return rowNumForSecionBlock(dataSource,section);
    // 下面的自定义
    return [self rowNum:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (headerHeightBlock) return headerHeightBlock(dataSource,section);
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(headerViewBlock) return headerViewBlock(dataSource,section);
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (footerHeightBlock) return footerHeightBlock(dataSource,section);
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if(footerViewBlock) return footerViewBlock(dataSource,section);
    return nil;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(rowHeightBlock)return rowHeightBlock(dataSource,indexPath);
    
    NSMutableArray *array =[self arrForSecion:indexPath.section];
    
    CSBaseLayoutModel *layout =array[indexPath.row];
    
    return layout.cellHeight;
    
    
    return UITableViewAutomaticDimension;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(willDisplayCellBlock) willDisplayCellBlock(dataSource,cell,indexPath);
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (cellForRowBlock) return cellForRowBlock(tableView,dataSource,indexPath);
    
    //下面的自定义
    
    NSMutableArray *array =[self arrForSecion:indexPath.section];
    
    CSBaseLayoutModel *layout = array[indexPath.row];
    
    CSBaseCell *cell =[tableView dequeueReusableCellWithIdentifier:layout.reuseIdentifier];
    
    
    
    cell.layout = layout;
    [cell addActionBlock:^(id action) {
        
        if (cellClickAction) cellClickAction(tableView,dataSource,indexPath,action);
        
    }];
    return cell;
    
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (rowClickAction)
    {
        rowClickAction(tableView,dataSource,indexPath,nil);
    }
    
    
    
}
-(NSInteger )secionNum{
    
    if ([dataSource isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *dic=dataSource;
        
        return [dic allKeys].count;
    }
    
    if ([dataSource isKindOfClass:[NSArray class]]) {
        
        
        return  1;
    }
    
    return 1;
}
-(NSInteger )rowNum:(NSInteger)secion{
    
    if ([dataSource isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *dic=dataSource;
        NSMutableArray *array=dic[[NSString stringWithFormat:@"%ld",(long)secion]];
        return array.count;
    }
    
    if ([dataSource isKindOfClass:[NSArray class]]) {
        
        
        NSMutableArray *array=dataSource;
        return array.count;
    }
    
    return 0;
}
-(NSMutableArray *)arrForSecion:(NSInteger )secion{
    
    if ([dataSource isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *dic=dataSource;
        NSMutableArray *array=dic[[NSString stringWithFormat:@"%ld", (long)secion]];
        return array;
    }
    
    if ([dataSource isKindOfClass:[NSArray class]]) {
        
        
        NSMutableArray *array=dataSource;
        return array;
    }
    
    return nil;
    
}



@end
