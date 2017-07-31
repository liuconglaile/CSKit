//
//  CSTextInput.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


/**
 文字位置关系.
 例如,偏移出现在行上的最后一个字符是反向相关性之后,在下一行的第一个字符之前是转发关联
 
 - CSTextAffinityForward: 偏移的字符之前出现
 - CSTextAffinityBackward: 偏移出现的字符之后
 */
typedef NS_ENUM(NSInteger, CSTextAffinity) {
    CSTextAffinityForward  = 0,
    CSTextAffinityBackward = 1
};




/**
 CSTextPosition对象表示文本容器中的位置;
 换句话说,它是文本显示视图中的支持字符串中的索引.
  
 CSTextPosition与Apple在UITextView/UITextField中的实现具有相同的API,
 所以你可以使用它与UITextView/UITextField进行交互.
 */
@interface CSTextPosition : UITextPosition


@property (nonatomic, readonly) NSInteger offset;
@property (nonatomic, readonly) CSTextAffinity affinity;

+ (instancetype)positionWithOffset:(NSInteger)offset;
+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(CSTextAffinity) affinity;

- (NSComparisonResult)compare:(id)otherPosition;

@end




/**
 CSTextRange对象表示文本容器中的一个字符范围; 
 换句话说,它在字符串中标识起始索引和结束索引,支持文本显示视图.
  
 CSTextRange具有与Apple在UITextView/UITextField中的实现相同的API,
 所以你可以使用它与UITextView/UITextField进行交互.
 */
@interface CSTextRange : UITextRange <NSCopying>

@property (nonatomic, readonly) CSTextPosition *start;
@property (nonatomic, readonly) CSTextPosition *end;
@property (nonatomic, readonly, getter=isEmpty) BOOL empty;

+ (instancetype)rangeWithRange:(NSRange)range;
+ (instancetype)rangeWithRange:(NSRange)range affinity:(CSTextAffinity) affinity;
+ (instancetype)rangeWithStart:(CSTextPosition *)start end:(CSTextPosition *)end;
+ (instancetype)defaultRange; ///< <{0,0} Forward>

- (NSRange)asRange;

@end


/**
 CSTextSelectionRect对象在文本显示视图中封装有关所选文本范围的信息.
  
 CSTextSelectionRect与Apple在UITextView/UITextField中的实现具有相同的API,
 所以你可以使用它与UITextView/UITextField进行交互.
 */
@interface CSTextSelectionRect : UITextSelectionRect <NSCopying>

@property (nonatomic, readwrite) CGRect rect;
@property (nonatomic, readwrite) UITextWritingDirection writingDirection;
@property (nonatomic, readwrite) BOOL containsStart;
@property (nonatomic, readwrite) BOOL containsEnd;
@property (nonatomic, readwrite) BOOL isVertical;

@end






NS_ASSUME_NONNULL_END
