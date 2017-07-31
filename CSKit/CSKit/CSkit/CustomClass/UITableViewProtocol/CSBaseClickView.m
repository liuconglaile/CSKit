//
//  CSBaseClickView.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSBaseClickView.h"

@implementation CSBaseClickView

{
    UIImage *_image;
    CGPoint _point;
    NSTimer *_timer;
    BOOL _longPressDetected;
}
-(void)setDefaultColor:(UIColor *)defaultColor{
    _defaultColor=defaultColor;
    self.backgroundColor=_defaultColor;
    
}
-(void)addTouchBlock:(CSBaseTouchBlock)block{
    
    _touchBlock=block;
    
}
-(void)addlongPressBlock:(CSBaseLongPressBlock)block{
    
    _longPressBlock=block;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_showClickEffect==YES) {
        
        self.backgroundColor=_selectColor;
    }
    
    _longPressDetected = NO;
    if (_touchBlock) {
        _touchBlock(self, CSBaseClickStateBegan, touches, event);
    }
    if (_longPressBlock) {
        UITouch *touch = touches.anyObject;
        _point = [touch locationInView:self];
        [self startTimer];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_showClickEffect==YES) {
        
        self.backgroundColor=_selectColor;
    }
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, CSBaseClickStateMoved, touches, event);
    }
    [self endTimer];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_showClickEffect==YES) {
            
            self.backgroundColor=_defaultColor;
        }
        
    });
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, CSBaseClickStateEnded, touches, event);
    }
    [self endTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_showClickEffect==YES) {
            self.backgroundColor=_defaultColor;
        }
        
        
    });
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, CSBaseClickStateCancelled, touches, event);
    }
    [self endTimer];
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
- (void)dealloc {
    [self endTimer];
}

@end




