//
//  CSImageBrowserModel.h
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CSImageBrowserModel : NSObject

@property (nonatomic,strong) UIImage* placeholder;//占位图
@property (nonatomic,strong) NSURL* thumbnailURL;//缩略图的URL
@property (nonatomic,strong) UIImage* thumbnailImage;//缩略图
@property (nonatomic,strong) NSURL* HDURL;//高清图的URL
@property (nonatomic,assign,readonly) BOOL isDownload;//高清图是否已经下载
@property (nonatomic,assign) CGRect originPosition;//原始位置（点击时，该图片位于UIWindow坐标系中的位置）
@property (nonatomic,assign,readonly) CGRect destinationFrame;//动画的目的地位置
@property (nonatomic,assign) NSInteger index;//标号



/**
 创建CSImageModel实例对象

 @param placeholder 占位图片
 @param thumbnailURL 略缩图URL
 @param HDURL 高清图URL
 @param containerView <#containerView description#>
 @param positionInContainer 原始位置
 @param index 标号
 @return CSImageModel实例对象
 */
- (id)initWithplaceholder:(UIImage *)placeholder
             thumbnailURL:(NSURL *)thumbnailURL
                    HDURL:(NSURL *)HDURL
            containerView:(UIView *)containerView
      positionInContainer:(CGRect)positionInContainer
                    index:(NSInteger)index;

@end
