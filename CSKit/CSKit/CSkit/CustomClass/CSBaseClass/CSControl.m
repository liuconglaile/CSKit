//
//  CSControl.m
//  CSKit
//
//  Created by mac on 2017/8/3.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSControl.h"
#import "CSKitMacro.h"

@implementation CSControl
{
    UIImage *_image;
    CGPoint _point;
    NSTimer *_timer;
    BOOL _longPressDetected;

}


- (void)setImage:(UIImage *)image {
    _image = image;
    self.layer.contents = (id)image.CGImage;
}

- (void)dealloc {
    [self endTimer];
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

- (void)startTimer {
    [_timer invalidate];
    _timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)endTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFire {
    [self touchesCancelled:[NSSet set] withEvent:nil];
    _longPressDetected = YES;
    if (_longPressBlock) _longPressBlock(self, _point);
    [self endTimer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _longPressDetected = NO;
    
    
    if (self.showClickEffect == YES) {
        
        self.backgroundColor = self.selectColor;
    }
    
    
    if (_touchBlock) {
        _touchBlock(self, CSGestureRecognizerStateBegan, touches, event);
    }
    if (_longPressBlock) {
        UITouch *touch = touches.anyObject;
        _point = [touch locationInView:self];
        [self startTimer];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.showClickEffect == YES) {
        
        self.backgroundColor = self.selectColor;
    }
    
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, CSGestureRecognizerStateMoved, touches, event);
    }
    [self endTimer];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (self.showClickEffect == YES) {
            
            self.backgroundColor = self.defaultColor;
        }
    });
    
    
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, CSGestureRecognizerStateEnded, touches, event);
    }
    [self endTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (self.showClickEffect == YES) {
            
            self.backgroundColor = self.defaultColor;
        }
    });
    
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, CSGestureRecognizerStateCancelled, touches, event);
    }
    [self endTimer];
}



- (void)setDefaultColor:(UIColor *)defaultColor{
    _defaultColor = defaultColor;
    self.backgroundColor = _defaultColor;
}

- (void)setSelectColor:(UIColor *)selectColor{
    _selectColor = selectColor;
}
- (void)setShowClickEffect:(BOOL)showClickEffect{
    _showClickEffect = showClickEffect;
}



@end
