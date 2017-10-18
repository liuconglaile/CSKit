//
//  NSAttributedString+Extended.m
//  CSKit
//
//  Created by mac on 2017/10/18.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "NSAttributedString+Extended.h"

const CGFloat AttributedString_Max_Height=1000.f;

@implementation NSAttributedString (Extended)

- (CGFloat)boundingHeightForWidth:(CGFloat)inWidth{
    
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) self);
    CGFloat height = [self boundingHeightWithFrameSetter:frameSetterRef ForWidth:inWidth];
    CFRelease(frameSetterRef);
    return height;
}

- (CGFloat)boundingHeightWithFrameSetter:(CTFramesetterRef)frameSetter ForWidth:(CGFloat)inWidth{
    
    CGFloat height = 0.f;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, Nil, CGRectMake(0, 0, inWidth, AttributedString_Max_Height));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    CFArrayRef linesArray = CTFrameGetLines(frameRef);
    CFIndex linesCount = CFArrayGetCount(linesArray);
    CGFloat lineHeight,ascent,descent,leading;
    for (int i=0; i<linesCount; i++) {
        CTLineRef currentLineRef = (CTLineRef)CFArrayGetValueAtIndex(linesArray, i);
        CTLineGetTypographicBounds(currentLineRef, &ascent, &descent, &leading);
        lineHeight = ascent+descent+leading;
        height += lineHeight;
    }
    
    CGPathRelease(path);
    CFRelease(frameRef);
    
    return height;
    
}

@end
