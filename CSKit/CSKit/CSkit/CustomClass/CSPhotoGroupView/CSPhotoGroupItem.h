//
//  CSPhotoGroupItem.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CSKit.h"

@interface CSPhotoGroupItem : NSObject

@property (nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize largeImageSize;
@property (nonatomic, strong) NSURL *largeImageURL;

@property (nonatomic, readonly) BOOL thumbClippedToTop;
@property (nonatomic, readonly) UIImage *thumbImage;

@end


@interface CSPhotoGroupCell : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) CSAnimatedImageView *imageView;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) CSPhotoGroupItem *item;
@property (nonatomic, readonly) BOOL itemDidLoad;
- (void)resizeSubviewSize;

@end
