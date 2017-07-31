//
//  CSPictureView.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSBaseClickView.h"


/**
 比UIImageView轻量的显示图片的View(带点击事件)
 */
@interface CSPictureView : CSBaseClickView

@property (nonatomic, strong) UIImage *image;

@end
