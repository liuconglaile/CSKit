//
//  CSProgeressHUD.m
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSProgeressHUD.h"

@interface CSProgeressHUD ()

@property (nonatomic,strong) CAShapeLayer* shapeLayer;

@end

const CGFloat kHUDSize = 70.0f;

@implementation CSProgeressHUD

+ (CSProgeressHUD *)showHUDAddedTo:(UIView *)view {
    CSProgeressHUD* hud = [[CSProgeressHUD alloc] initWithFrame:CGRectMake(0, 0, kHUDSize, kHUDSize)];
    hud.center = view.center;
    hud.progress = 0.0f;
    [view addSubview:hud];
    return hud;
}


+ (void)hideAllHUDForView:(UIView *)view {
    for (UIView* subView in view.subviews) {
        if ([subView isMemberOfClass:[CSProgeressHUD class]]) {
            [subView removeFromSuperview];
        }
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.shapeLayer.strokeEnd = self.progress;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 8.0f;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.75f];
        
        UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:self.center
                                                            radius:25.0f
                                                        startAngle:-M_PI/2
                                                          endAngle:3.0f/2 * M_PI
                                                         clockwise:YES];
        
        CAShapeLayer* shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = 2.0f;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.strokeStart = 0.0f;
        shapeLayer.strokeEnd = 1.0f;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        [self.layer addSublayer:shapeLayer];
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.path = path.CGPath;
        self.shapeLayer.lineWidth = 2.0f;
        self.shapeLayer.lineCap = kCALineCapRound;
        self.shapeLayer.strokeStart = 0.0f;
        self.shapeLayer.strokeEnd = 0.0f;
        self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
        self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:self.shapeLayer];
    }
    return self;
}

@end
