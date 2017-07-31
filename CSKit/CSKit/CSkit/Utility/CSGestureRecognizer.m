//
//  CSGestureRecognizer.m
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation CSGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateBegan;
    _startPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
    _lastPoint = _currentPoint;
    _currentPoint = _startPoint;
    if (_action) _action(self, CSGestureRecognizerStateBegan);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    self.state = UIGestureRecognizerStateChanged;
    _currentPoint = currentPoint;
    if (_action) _action(self, CSGestureRecognizerStateMoved);
    _lastPoint = _currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateEnded;
    if (_action) _action(self, CSGestureRecognizerStateEnded);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateCancelled;
    if (_action) _action(self, CSGestureRecognizerStateCancelled);
}

- (void)reset {
    self.state = UIGestureRecognizerStatePossible;
}

- (void)cancel {
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateCancelled;
        if (_action) _action(self, CSGestureRecognizerStateCancelled);
    }
}

@end
