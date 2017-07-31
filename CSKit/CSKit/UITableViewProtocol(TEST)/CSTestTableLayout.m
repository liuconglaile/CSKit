//
//  CSTestTableLayout.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTestTableLayout.h"
#import "CSTestTableModel.h"
#import "CSKit.h"

#define NAMEFONT [UIFont systemFontOfSize:15]    //用户名字体
#define NAMECOLOR UIColorHex(333333)             //用户名颜色
#define NAMETOP   15                             //用户名距离上方距离
#define NAMELEFT  10                             //用户名距离头像左右距离
#define AVTARX    15                             //头像距离上方距离
#define AVTARY    10                             //头像距离左右距离
#define AVTARW    50                             //头像宽
#define AVTARH    50                             //头像高
#define CONTENTFONT [UIFont systemFontOfSize:15] //用户名字体
#define CONTENTCOLOR UIColorHex(666666)          //用户名颜色

@implementation CSTestTableLayout

-(void )celllayout{
    
    CSTestTableModel * feed = self.dataModel;
    
    self.cellHeight=0;
    _avtarFrame =CGRectMake(AVTARX, AVTARY, AVTARW, AVTARH);
    self.cellHeight+=AVTARY+AVTARH;
    
    
    _userNameLayout = [self layout:NAMEFONT color:NAMECOLOR width:kScreenWidth-2*NAMELEFT-AVTARX-AVTARW string:feed.userName max:YES];
    
    _timeLayout = [self layout:[UIFont systemFontOfSize:13] color:NAMECOLOR width:kScreenWidth-2*NAMELEFT-AVTARX-AVTARW string:feed.time max:YES];
    
    
    if (feed.content.length > 0) {
        
        
        CSTextLayout *fiveLine = [self layout:CONTENTFONT color:CONTENTCOLOR width:kScreenWidth-2*NAMELEFT-AVTARX-AVTARW string:feed.content max:NO];
        CSTextLayout *maxLine  = [self layout:CONTENTFONT color:CONTENTCOLOR width:kScreenWidth-2*NAMELEFT-AVTARX-AVTARW string:feed.content max:YES];
        
        if (_isOpen) {
            _contentLayout = maxLine;
        }else{
            _contentLayout = fiveLine;
        }
        
        
        self.cellHeight += _contentLayout.textBoundingSize.height+10;
        //不显示收起按钮
        if (maxLine.textBoundingSize.height == fiveLine.textBoundingSize.height) {
            _allBtnFrame = CGRectZero;
        }else{
            _allBtnFrame = CGRectMake(CGRectGetMinX(_avtarFrame), self.cellHeight+5, 35, 20);
            
            self.cellHeight += CGRectGetHeight(_allBtnFrame)+5;
        }
    }
    
    
    if(feed.imageArr.count>0){
        
        _imageSizeArr=[NSMutableArray array];
        NSInteger num=3;//每行最大数量
        NSInteger speace=5;//每张图片之间的间隔
        NSInteger startX= CGRectGetMinX(_avtarFrame);
        NSInteger startY= self.cellHeight+10;
        __block  NSInteger x =startX;
        __block  NSInteger y = startY;
        
        if (feed.imageArr.count<3) {
            num=feed.imageArr.count;
        }
        
        if (feed.imageArr.count==4) {
            num=2;
        }
        NSInteger w=(kScreenWidth - startX - NAMELEFT-(num-1)*speace)/num;
        
        
        [feed.imageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            x =idx%num*(w+speace)+startX;
            y =idx/num*(w+speace)+startY;
            CGRect rect=CGRectMake(x, y, w, w);
            [_imageSizeArr addObject:NSStringFromCGRect(rect)];
            
            if (idx == feed.imageArr.count-1) {
                self.cellHeight=y+w+10;
            }
            
        }];
        
    }else{
        
        self.cellHeight+=10;
    }
    
    
}

@end
