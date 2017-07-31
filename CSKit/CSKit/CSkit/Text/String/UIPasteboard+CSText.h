//
//  UIPasteboard+CSText.h
//  CSCategory
//
//  Created by mac on 2017/7/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


/**
 扩展UIPasteboard支持图像和富文本字符串
 */
@interface UIPasteboard (CSText)

@property (nullable, nonatomic, copy) NSData *PNGData;    ///< PNG file data
@property (nullable, nonatomic, copy) NSData *JPEGData;   ///< JPEG file data
@property (nullable, nonatomic, copy) NSData *GIFData;    ///< GIF file data
@property (nullable, nonatomic, copy) NSData *WEBPData;   ///< WebP file data
@property (nullable, nonatomic, copy) NSData *imageData;  ///< image file data

/// 富文本字符串,设置此属性还将从富文本字符串复制的富文本字符串的文本属性。
/// 如果富文本字符串中包含一个或多个图像,它也将设置'images'属性.
@property (nullable, nonatomic, copy) NSAttributedString *attributedString;

@end

/// 在粘贴板中标识富文本字符的文本属性名称.
UIKIT_EXTERN NSString *const CSPasteboardTypeAttributedString;

/// 在粘贴板中标识WebP数据UTI类型
UIKIT_EXTERN NSString *const CSUTTypeWEBP;

NS_ASSUME_NONNULL_END



