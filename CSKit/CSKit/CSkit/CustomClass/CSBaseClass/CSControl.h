//
//  CSControl.h
//  CSKit
//
//  Created by mac on 2017/8/3.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGestureRecognizer.h"

@interface CSControl : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void (^touchBlock)(CSControl *view, CSGestureRecognizerState state, NSSet *touches, UIEvent *event);
@property (nonatomic, copy) void (^longPressBlock)(CSControl *view, CGPoint point);


@property(strong,nonatomic) UIColor* selectColor;//选中颜色;
@property(strong,nonatomic) UIColor* defaultColor;//默认颜色;
@property(assign,nonatomic) BOOL  showClickEffect;//显示点击效果;


@end
