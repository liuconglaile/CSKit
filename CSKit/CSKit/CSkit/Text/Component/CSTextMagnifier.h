//
//  CSTextMagnifier.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSTextAttribute.h>
#else
#import "CSTextAttribute.h"
#endif

NS_ASSUME_NONNULL_BEGIN



/**
 放大镜类型

 - CSTextMagnifierTypeCaret: 圆形放大镜
 - CSTextMagnifierTypeRanged: 圆角矩形放大镜
 */
typedef NS_ENUM(NSInteger, CSTextMagnifierType) {
    CSTextMagnifierTypeCaret,
    CSTextMagnifierTypeRanged
};

/**
 可以在'CSTextEffectWindow'中显示的放大镜视图.
  
 @discussion 使用'magnifierWithType:'创建实例.
             通常,你不应该直接使用这个类。
 */
@interface CSTextMagnifier : UIView


/**
 创建一个具有指定类型的放大镜

 @param type 放大镜类型
 */
+ (id)magnifierWithType:(CSTextMagnifierType)type;

@property (nonatomic, readonly) CSTextMagnifierType type;  ///< 放大镜类型
@property (nonatomic, readonly) CGSize fitSize;            ///< 放大镜视图的'最佳'尺寸.
@property (nonatomic, readonly) CGSize snapshotSize;       ///< 放大镜的'最佳'快照图像大小.
@property (nullable, nonatomic, strong) UIImage *snapshot; ///< 放大镜中的图像 (readwrite).

@property (nullable, nonatomic, weak) UIView *hostView;    ///< 基于坐标的视图.
@property (nonatomic) CGPoint hostCaptureCenter;           ///< 'hostView'中的快照捕获中心.
@property (nonatomic) CGPoint hostPopoverCenter;           ///< 'hostView'中的popover中心.
@property (nonatomic) BOOL hostVerticalForm;               ///< 宿主视图是垂直形式.
@property (nonatomic) BOOL captureDisabled;                ///< 提示'CSTextEffectWindow'禁用捕获.
@property (nonatomic) BOOL captureFadeAnimation;           ///< 快照图像更改时的渐变动画.


@end
NS_ASSUME_NONNULL_END


