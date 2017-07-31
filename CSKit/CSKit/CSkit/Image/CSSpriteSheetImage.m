//
//  CSSpriteSheetImage.m
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSSpriteSheetImage.h"

@implementation CSSpriteSheetImage

- (instancetype)initWithSpriteSheetImage:(UIImage *)image
                            contentRects:(NSArray *)contentRects
                          frameDurations:(NSArray *)frameDurations
                               loopCount:(NSUInteger)loopCount {
    if (!image.CGImage) return nil;
    if (contentRects.count < 1 || frameDurations.count < 1) return nil;
    if (contentRects.count != frameDurations.count) return nil;
    
    self = [super initWithCGImage:image.CGImage scale:image.scale orientation:image.imageOrientation];
    if (!self) return nil;
    
    _contentRects = contentRects.copy;
    _frameDurations = frameDurations.copy;
    _loopCount = loopCount;
    return self;
}

- (CGRect)contentsRectForCALayerAtIndex:(NSUInteger)index {
    CGRect layerRect = CGRectMake(0, 0, 1, 1);
    if (index >= _contentRects.count) return layerRect;
    
    CGSize imageSize = self.size;
    CGRect rect = [self animatedImageContentsRectAtIndex:index];
    if (imageSize.width > 0.01 && imageSize.height > 0.01) {
        layerRect.origin.x = rect.origin.x / imageSize.width;
        layerRect.origin.y = rect.origin.y / imageSize.height;
        layerRect.size.width = rect.size.width / imageSize.width;
        layerRect.size.height = rect.size.height / imageSize.height;
        layerRect = CGRectIntersection(layerRect, CGRectMake(0, 0, 1, 1));
        if (CGRectIsNull(layerRect) || CGRectIsEmpty(layerRect)) {
            layerRect = CGRectMake(0, 0, 1, 1);
        }
    }
    return layerRect;
}

#pragma mark @protocol YYAnimatedImage

- (NSUInteger)animatedImageFrameCount {
    return _contentRects.count;
}

- (NSUInteger)animatedImageLoopCount {
    return _loopCount;
}

- (NSUInteger)animatedImageBytesPerFrame {
    return 0;
}

- (UIImage *)animatedImageFrameAtIndex:(NSUInteger)index {
    return self;
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index {
    if (index >= _frameDurations.count) return 0;
    return ((NSNumber *)_frameDurations[index]).doubleValue;
}

- (CGRect)animatedImageContentsRectAtIndex:(NSUInteger)index {
    if (index >= _contentRects.count) return CGRectZero;
    return ((NSValue *)_contentRects[index]).CGRectValue;
}

@end




