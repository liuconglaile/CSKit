//
//  CSGestureRecognizer.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


/**
 手势的状态

 - CSGestureRecognizerStateBegan: 手势开始
 - CSGestureRecognizerStateMoved: 手势移动
 - CSGestureRecognizerStateEnded: 手势结束
 - CSGestureRecognizerStateCancelled: 手势取消
 */
typedef NS_ENUM(NSUInteger, CSGestureRecognizerState) {
    CSGestureRecognizerStateBegan,
    CSGestureRecognizerStateMoved,
    CSGestureRecognizerStateEnded,
    CSGestureRecognizerStateCancelled,
};


/**
 一个简单的UIGestureRecognizer子类,用于接收触摸事件.
 */
@interface CSGestureRecognizer : UIGestureRecognizer

/** 起点 */
@property (nonatomic, readonly) CGPoint startPoint;
/** 终止点 */
@property (nonatomic, readonly) CGPoint lastPoint;
/** 当前移动点 */
@property (nonatomic, readonly) CGPoint currentPoint;

/** 每个手势事件调用的动作块 */
@property (nullable, nonatomic, copy) void (^action)(CSGestureRecognizer *gesture, CSGestureRecognizerState state);

/** 取消当前触摸的手势 */
- (void)cancel;

@end
NS_ASSUME_NONNULL_END

