//
//  CSTextDebugOption.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@protocol CSTextDebugTarget;
NS_ASSUME_NONNULL_BEGIN


/**
 CSText的调试选项.
 */
@interface CSTextDebugOption : NSObject<NSCopying>
@property (nullable, nonatomic, strong) UIColor *baselineColor;      ///< 基线颜色
@property (nullable, nonatomic, strong) UIColor *CTFrameBorderColor; ///< CTFrame 路径边框颜色
@property (nullable, nonatomic, strong) UIColor *CTFrameFillColor;   ///< CTFrame 路径填充颜色
@property (nullable, nonatomic, strong) UIColor *CTLineBorderColor;  ///< CTLine 边界边框颜色
@property (nullable, nonatomic, strong) UIColor *CTLineFillColor;    ///< CTLine 边界填充颜色
@property (nullable, nonatomic, strong) UIColor *CTLineNumberColor;  ///< CTLine 行号颜色
@property (nullable, nonatomic, strong) UIColor *CTRunBorderColor;   ///< CTRun 界定边框颜色
@property (nullable, nonatomic, strong) UIColor *CTRunFillColor;     ///< CTRun 边界填充颜色
@property (nullable, nonatomic, strong) UIColor *CTRunNumberColor;   ///< CTRun 号码颜色
@property (nullable, nonatomic, strong) UIColor *CGGlyphBorderColor; ///< CGGlyph 界限边框颜色
@property (nullable, nonatomic, strong) UIColor *CGGlyphFillColor;   ///< CGGlyph 边界填充颜色

- (BOOL)needDrawDebug; ///< YES:至少有一个调试颜色可见.NO:所有调试颜色都是不可见/nil.
- (void)clear; ///< 将所有调试颜色设置为nil.

/**
 添加调试目标.
 
 @discussion 
 当调用'setSharedDebugOption:'时,所有添加的调试目标将在主线程中接收'setDebugOption:'. 
 它维护对此目标的unsafe_untained引用.目标必须在dealloc之前删除

 @param target 调试目标.
 */
+ (void)addDebugTarget:(id<CSTextDebugTarget>)target;

/**
 删除由'addDebugTarget:'添加的调试目标
 
 @param target 调试目标.
 */
+ (void)removeDebugTarget:(id<CSTextDebugTarget>)target;

/**
 返回共享调试选项.
 
 @return 默认为 nil.
 */
+ (nullable CSTextDebugOption *)sharedDebugOption;

/**
 将调试选项设置为共享调试选项.
 必须在主线程上调用此方法.
 
 @discussion 当调用此方法时,新选项将设置为由'addDebugTarget:'添加的所有调试目标.
 
 @param option  一个新的调试选项 (nil is valid).
 */
+ (void)setSharedDebugOption:(nullable CSTextDebugOption *)option;




@end




/**
 CSTextDebugTarget协议定义调试目标应实现的方法.
 调试目标可以添加到全局容器以接收共享调试选项更改的通知
 */
@protocol CSTextDebugTarget <NSObject>

@required
/**
 当共享调试选项更改时,该方法将在主线程上调用.
 它应该尽可能快地返回.该方法不应更改该选项的属性.
 
 @param option  共享调试选项.
 */
- (void)setDebugOption:(nullable CSTextDebugOption *)option;

@end


NS_ASSUME_NONNULL_END


