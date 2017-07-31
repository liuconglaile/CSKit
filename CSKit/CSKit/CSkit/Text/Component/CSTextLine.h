//
//  CSTextLine.h
//  CSCategory
//
//  Created by mac on 17/4/8.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>


#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSTextAttribute.h>
#else
#import "CSTextAttribute.h"
#endif

@class CSTextRunGlyphRange;

NS_ASSUME_NONNULL_BEGIN


/** 
 对CTLineRef的封装
 
 一个文本行对象包含'CTLineRef',详见'CSTextLayout'
 */
@interface CSTextLine : NSObject

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position vertical:(BOOL)isVertical;

@property (nonatomic) NSUInteger index;     ///< line index
@property (nonatomic) NSUInteger row;       ///< line row
@property (nullable, nonatomic, strong) NSArray<NSArray<CSTextRunGlyphRange *> *> *verticalRotateRange; ///< Run rotate range

@property (nonatomic, readonly) CTLineRef CTLine;   ///< CoreText line
@property (nonatomic, readonly) NSRange range;      ///< string range
@property (nonatomic, readonly) BOOL vertical;      ///< vertical form

@property (nonatomic, assign, readonly) CGRect frame; //加上ascent和descent之后的frame,UIKit坐标系
@property (nonatomic, readonly) CGRect bounds;      ///< bounds (ascent + descent)
@property (nonatomic, readonly) CGSize size;        ///< bounds.size
@property (nonatomic, readonly) CGFloat width;      ///< bounds.size.width
@property (nonatomic, readonly) CGFloat height;     ///< bounds.size.height
@property (nonatomic, readonly) CGFloat top;        ///< bounds.origin.y
@property (nonatomic, readonly) CGFloat bottom;     ///< bounds.origin.y + bounds.size.height
@property (nonatomic, readonly) CGFloat left;       ///< bounds.origin.x
@property (nonatomic, readonly) CGFloat right;      ///< bounds.origin.x + bounds.size.width

@property (nonatomic)   CGPoint position;   ///< baseline position
@property (nonatomic, readonly) CGFloat ascent;     ///< line ascent
@property (nonatomic, readonly) CGFloat descent;    ///< line descent
@property (nonatomic, readonly) CGFloat leading;    ///< line leading
@property (nonatomic, readonly) CGFloat lineWidth;  ///< line width
@property (nonatomic, readonly) CGFloat trailingWhitespaceWidth;

//@property (nonatomic, copy, readonly) NSArray<CSTextGlyph *>* glyphs;//保存CGGlyph封装对象的数组
@property (nullable, nonatomic, readonly) NSArray<CSTextAttachment *> *attachments; ///< CSTextAttachment
@property (nullable, nonatomic, readonly) NSArray<NSValue *> *attachmentRanges;     ///< NSRange(NSValue)
@property (nullable, nonatomic, readonly) NSArray<NSValue *> *attachmentRects;      ///< CGRect(NSValue)







@end






/**
 雕文绘制模式

 - CSTextRunGlyphDrawModeHorizontal: 不旋转
 - CSTextRunGlyphDrawModeVerticalRotate: 旋转垂直为单个字形
 - CSTextRunGlyphDrawModeVerticalRotateMove: 为单个字形旋转垂直,并将字形移动到更好的位置,例如全角标点符号
 */
typedef NS_ENUM(NSUInteger, CSTextRunGlyphDrawMode) {
    CSTextRunGlyphDrawModeHorizontal = 0,
    CSTextRunGlyphDrawModeVerticalRotate = 1,
    CSTextRunGlyphDrawModeVerticalRotateMove = 2,
};


@interface CSTextRunGlyphRange : NSObject
@property (nonatomic) NSRange glyphRangeInRun;
@property (nonatomic) CSTextRunGlyphDrawMode drawMode;
+ (instancetype)rangeWithRange:(NSRange)range drawMode:(CSTextRunGlyphDrawMode)mode;
@end



NS_ASSUME_NONNULL_END



