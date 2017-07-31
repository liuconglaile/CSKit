//
//  CSImageItem.h
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSImageBrowserModel.h"

#import "CSWebImageManager.h"
#import "UIImageView+CSWebImage.h"

@protocol CSImageItemEventDelegate <NSObject>

@optional

- (void)didClickedItemToHide;
- (void)didFinishedDownLoadHDImage;

@end

@interface CSImageItem : UIScrollView

@property (nonatomic,weak) id <CSImageItemEventDelegate> eventDelegate;
@property (nonatomic,strong) CSImageBrowserModel* imageModel;
@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,assign,getter=isFirstShow) BOOL firstShow;

- (void)loadHdImage:(BOOL)animated;

@end
