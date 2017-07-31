//
//  CSPictureView.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSPictureView.h"

@implementation CSPictureView
{
    UIImage *_image;
}
- (void)setImage:(UIImage *)image {
    _image = image;
    self.layer.contents = (id)image.CGImage;
}
- (UIImage *)image {
    id content = self.layer.contents;
    if (content != (id)_image.CGImage) {
        CGImageRef ref = (__bridge CGImageRef)(content);
        if (ref && CFGetTypeID(ref) == CGImageGetTypeID()) {
            _image = [UIImage imageWithCGImage:ref scale:self.layer.contentsScale orientation:UIImageOrientationUp];
        } else {
            _image = nil;
        }
    }
    return _image;
}

@end
