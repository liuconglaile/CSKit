//
//  CSAsyncLayer.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/QuartzCore.h>
@class CSAsyncLayerDisplayTask;
NS_ASSUME_NONNULL_BEGIN



/**
 调用该块来绘制图层的内容
 可以在主线程或后台线程上调用此块,所以应该是线程安全的
 
 @param context 由图层创建的新位图内容
 @param size 内容大小(通常与图层的边界大小相同)
 @param isCancelled 如果此块返回'YES',则该方法应该取消绘图过程尽快返回
 */
typedef void (^CSAsyncLayerDisplay)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));


/**
 异步绘图完成后将调用此块.它将在主线程上被调用.
 
 @param layer 层
 @param finished 如果绘制过程被取消,它是'否',否则它是'YES'
 */
typedef void (^CSAsyncLayerDidDisplay)(CALayer *layer, BOOL finished);








/**
 CSAsyncLayer类是用于异步呈现内容的CALayer的子类.
 @discussion 当层需要更新它的内容时,它将要求代理进行异步显示任务,以在后台队列中呈现内容.
 */
@interface CSAsyncLayer : CALayer

/// 渲染代码是否在后台执行. Default is YES.
@property BOOL displaysAsynchronously;

@end






/** CSAsyncLayer的委托协议.CSAsyncLayer的代理者(通常是UIView)必须实现本协议中的方法. */
@protocol CSAsyncLayerDelegate <NSObject>

@required
/// 当层的内容需要更新时,调用此方法返回新的显示任务.
- (CSAsyncLayerDisplayTask *)newAsyncDisplayTask;
@end




/** CSAsyncLayer用于在后台队列中呈现内容的显示任务. */
@interface CSAsyncLayerDisplayTask : NSObject


/** 在异步绘图开始之前,将调用此块.它将在主线程上被调用 */
@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);

/** 调用该块来绘制图层的内容 */
@property (nullable, nonatomic, copy) CSAsyncLayerDisplay display;// void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));

/** 异步绘图完成后将调用此块.它将在主线程上被调用 */
@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end





NS_ASSUME_NONNULL_END

