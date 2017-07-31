//
//  CSBaseClickView.h
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>



/**
 手势枚举

 - CSBaseClickStateBegan: 手势开始
 - CSBaseClickStateMoved: 手势移动
 - CSBaseClickStateEnded: 手势结束
 - CSBaseClickStateCancelled: 手势取消
 */
typedef NS_ENUM(NSUInteger, CSBaseClickState) {
    CSBaseClickStateBegan,
    CSBaseClickStateMoved,
    CSBaseClickStateEnded,
    CSBaseClickStateCancelled
};

/**
 有点击效果的 view
 */
@interface CSBaseClickView : UIView

typedef void(^CSBaseTouchBlock)(CSBaseClickView *view, CSBaseClickState state, NSSet *touches, UIEvent *event);

typedef void(^CSBaseLongPressBlock)(CSBaseClickView *view, CGPoint point);

@property (nonatomic, copy) CSBaseTouchBlock touchBlock;
@property (nonatomic, copy) CSBaseLongPressBlock longPressBlock;

@property(strong,nonatomic)UIColor*selectColor;//选中颜色;
@property(strong,nonatomic)UIColor*defaultColor;//默认颜色;
@property(assign,nonatomic)BOOL showClickEffect;//显示点击效果;

- (void)addTouchBlock:(CSBaseTouchBlock)block;
- (void)addlongPressBlock:(CSBaseLongPressBlock)block;

@end
