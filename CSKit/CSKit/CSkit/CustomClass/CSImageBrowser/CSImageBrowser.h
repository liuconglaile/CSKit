//
//  CSImageBrowser.h
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSImageBrowserCell.h"

@interface CSImageBrowser : UIViewController

@property (nonatomic,assign) BOOL isScalingToHide;//消失的时候是否启动缩放动画
@property (nonatomic,assign) BOOL isShowPageControl;//是否显示页码



/**
 构造方法

 @param imageModels 一个存放CSImageBrowserModel的数组
 @param index 点击的图片在数组中所处的位置
 @return 图片展示器
 */
- (instancetype)initWithImageBrowserModels:(NSArray<CSImageBrowserModel*>*)imageModels currentIndex:(NSInteger)index;

/**
 *  显示图片浏览器
 */
- (void)show;

@end
