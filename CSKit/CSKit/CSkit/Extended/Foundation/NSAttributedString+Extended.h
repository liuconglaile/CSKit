//
//  NSAttributedString+Extended.h
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>

@interface NSAttributedString (Extended)

- (CGFloat)boundingHeightForWidth:(CGFloat)inWidth;
- (CGFloat)boundingHeightWithFrameSetter:(CTFramesetterRef)frameSetter ForWidth:(CGFloat)inWidth;

@end
