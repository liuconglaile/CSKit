//
//  UIView+Layout.m
//  CSCategory
//
//  Created by mac on 2017/7/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIView+Layout.h"

@implementation UIView (Layout)


///MARK: ===================================================
///MARK: Frame相关
///MARK: ===================================================
/**
 将点从接收器的坐标系转换为指定的视图或窗口.
 
 @param point 在接收器的局部坐标系(bounds)中指定的点.
 @param view  要转换其坐标系点的视图或窗口. 如果视图为nil,则将该方法转换为window基坐标.
 @return 转换为坐标系的点.
 */
- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point toWindow:nil];
        } else {
            return [self convertPoint:point toView:nil];
        }
    }
    
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point toView:view];
    point = [self convertPoint:point toView:from];
    point = [to convertPoint:point fromWindow:from];
    point = [view convertPoint:point fromView:to];
    return point;
}


/**
 将点从给定视图或window的坐标系转换为接收器.
 
 @param point 在局部坐标系(bounds)中指定的点.
 @param view  视图或window与其坐标系中的点. 如果视图为nil,则该方法转换为window基坐标s.
 @return 点转换为接收器的局部坐标系(bounds).
 */
- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point fromWindow:nil];
        } else {
            return [self convertPoint:point fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point fromView:view];
    point = [from convertPoint:point fromView:view];
    point = [to convertPoint:point fromWindow:from];
    point = [self convertPoint:point fromView:to];
    return point;
}

/**
 将矩形从接收器的坐标系转换为另一个视图或window.
 
 @param rect 在接收器的局部坐标系(bounds)中指定的矩形.
 @param view 作为转换操作目标的视图或窗口.如果视图为nil,则将该方法转换为window基坐标.
 @return 转换矩形.
 */
- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect toWindow:nil];
        } else {
            return [self convertRect:rect toView:nil];
        }
    }
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!from || !to) return [self convertRect:rect toView:view];
    if (from == to) return [self convertRect:rect toView:view];
    rect = [self convertRect:rect toView:from];
    rect = [to convertRect:rect fromWindow:from];
    rect = [view convertRect:rect fromView:to];
    return rect;
}


/**
 将矩形从另一个视图或window的坐标系转换为接收器的坐标系.
 
 @param rect 在接收器的局部坐标系(bounds)中指定的矩形
 @param view 在其坐标系中具有rect的视图或window.如果视图为nil,则该方法将转换为窗口基坐标.
 @return 转换矩形.
 */
- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect fromWindow:nil];
        } else {
            return [self convertRect:rect fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertRect:rect fromView:view];
    rect = [from convertRect:rect fromView:view];
    rect = [to convertRect:rect fromWindow:from];
    rect = [self convertRect:rect fromView:to];
    return rect;
}



- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x + self.frame.size.width * 0.5;
}

- (void)setCenterX:(CGFloat)centerX {
    
    CGRect frame = self.frame;
    frame.origin.x = centerX - frame.size.width * 0.5;
    self.frame = frame;
    
    //self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    //return self.center.y;
    
    return self.center.y + self.frame.size.height * 0.5;
}

- (void)setCenterY:(CGFloat)centerY {
    //self.center = CGPointMake(self.center.x, centerY);
    
    CGRect frame = self.frame;
    frame.origin.y = centerY - frame.size.height * 0.5;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

///MARK: ===================================================
///MARK: Frame相关
///MARK: ===================================================





/////MARK: ===================================================
/////MARK: 约束相关
/////MARK: ===================================================
//
//- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute {
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d && (firstItem = %@ || secondItem = %@)", attribute, self, self];
//    NSArray *constraintArray = [self.superview constraints];
//    
//    if (attribute == NSLayoutAttributeWidth || attribute == NSLayoutAttributeHeight) {
//        constraintArray = [self constraints];
//    }
//    
//    NSArray *fillteredArray = [constraintArray filteredArrayUsingPredicate:predicate];
//    if(fillteredArray.count == 0) {
//        return nil;
//    } else {
//        return fillteredArray.firstObject;
//    }
//}
//
//- (NSLayoutConstraint *)leftConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeLeft];
//}
//
//- (NSLayoutConstraint *)rightConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeRight];
//}
//
//- (NSLayoutConstraint *)topConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeTop];
//}
//
//- (NSLayoutConstraint *)bottomConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeBottom];
//}
//
//- (NSLayoutConstraint *)leadingConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeLeading];
//}
//
//- (NSLayoutConstraint *)trailingConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeTrailing];
//}
//
//- (NSLayoutConstraint *)widthConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeWidth];
//}
//
//- (NSLayoutConstraint *)heightConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeHeight];
//}
//
//- (NSLayoutConstraint *)centerXConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeCenterX];
//}
//
//- (NSLayoutConstraint *)centerYConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeCenterY];
//}
//
//- (NSLayoutConstraint *)baseLineConstraint {
//    return [self constraintForAttribute:NSLayoutAttributeBaseline];
//}
//
//
//- (NSArray *)makeConstraints:(void (^)(CSConstraintMaker *))aBlock{
//    self.translatesAutoresizingMaskIntoConstraints = NO;
//    CSConstraintMaker *constraintMaker = [[CSConstraintMaker alloc] initWithView:self];
//    aBlock(constraintMaker);
//    return [constraintMaker install];
//}
//
/////MARK: ===================================================
/////MARK: 约束相关
/////MARK: ===================================================







@end





typedef NS_ENUM(NSUInteger, CSLayoutAttribute) {
    CSLayoutAttributeEdges = 0,
    CSLayoutAttributeSize,
    CSLayoutAttributeCenter
};


//@interface CSConstraintMaker()
//
//@property (nonatomic, weak) UIView *view;
//@property (nonatomic, strong) NSMutableArray<CSConstraint *> *constraints;
//
//@end
//
//@implementation CSConstraintMaker
//
//- (id)initWithView:(UIView *)view {
//    if (self = [super init]) {
//        self.view = view;
//        self.constraints = [NSMutableArray new];
//    }
//    return self;
//}
//
//- (NSArray *)install {
//    NSArray *constraints = self.constraints.copy;
//    for (CSConstraint *constraint in constraints) {
//        [constraint install];
//    }
//    return constraints;
//}
//
//- (CSConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
//    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
//}
//
//- (CSConstraint *)constraint:(CSConstraint *)aConstraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
//    CSConstraint *constraint = [[CSConstraint alloc] initWithView:self.view];
//    constraint.layoutAttributes = [NSMutableArray arrayWithObjects:@(layoutAttribute), nil];
//    [self.constraints addObject:constraint];
//    return constraint;
//}
//
//- (CSConstraint *)left {
//    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
//}
//
//- (CSConstraint *)top {
//    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
//}
//
//- (CSConstraint *)right {
//    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
//}
//
//- (CSConstraint *)bottom {
//    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
//}
//
//- (CSConstraint *)width {
//    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
//}
//
//- (CSConstraint *)height {
//    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
//}
//
//- (CSConstraint *)centerX {
//    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
//}
//
//- (CSConstraint *)centerY {
//    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
//}
//
//- (CSConstraint *)edges {
//    return [self _addConstraintWithLayoutAttribute:CSLayoutAttributeEdges];
//}
//
//- (CSConstraint *)size {
//    return [self _addConstraintWithLayoutAttribute:CSLayoutAttributeSize];
//}
//
//- (CSConstraint *)center {
//    return [self _addConstraintWithLayoutAttribute:CSLayoutAttributeCenter];
//}
//
//- (CSConstraint *)_addConstraintWithLayoutAttribute:(CSLayoutAttribute)layoutAttribute {
//    CSConstraint *constraint = [[CSConstraint alloc] initWithView:self.view];
//    constraint.layoutAttributes = [self layoutAttribute:layoutAttribute];
//    [self.constraints addObject:constraint];
//    return constraint;
//}
//
//- (NSMutableArray *)layoutAttribute:(CSLayoutAttribute)layoutAttribute {
//    switch (layoutAttribute) {
//        case CSLayoutAttributeEdges:
//            return [NSMutableArray arrayWithObjects:
//                    @(NSLayoutAttributeLeft),
//                    @(NSLayoutAttributeTop),
//                    @(NSLayoutAttributeBottom),
//                    @(NSLayoutAttributeRight), nil];
//        case CSLayoutAttributeSize:
//            return [NSMutableArray arrayWithObjects:
//                    @(NSLayoutAttributeWidth),
//                    @(NSLayoutAttributeHeight), nil];
//        case CSLayoutAttributeCenter:
//            return [NSMutableArray arrayWithObjects:
//                    @(NSLayoutAttributeCenterX),
//                    @(NSLayoutAttributeCenterY), nil];
//        default: break;
//    }
//}
//
//
//@end
//
//
//@implementation CSConstraint{
//    NSMutableArray* _constraints;
//}
//
//- (instancetype)initWithView:(UIView *)aView{
//    if (self = [super init]) {
//        _constraints = [[NSMutableArray alloc] init];
//        self.firstItem = aView;
//    }
//    return self;
//}
//
//- (void)install{
//    [self.firstItem.superview addConstraints:_constraints];
//}
//
//- (CSConstraint *)equalToView:(UIView *)aView{
//    for (NSNumber *obj in self.layoutAttributes) {
//        NSLayoutAttribute attr = (NSLayoutAttribute)obj.integerValue;
//        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.firstItem
//                                                                      attribute:attr
//                                                                      relatedBy:NSLayoutRelationEqual
//                                                                         toItem:aView
//                                                                      attribute:attr
//                                                                     multiplier:1
//                                                                       constant:0];
//        [_constraints addObject:constraint];
//    }
//    return self;
//}
//
//- (CSConstraint *)equalTo:(CGFloat)c{
//    for (NSNumber *obj in self.layoutAttributes) {
//        NSLayoutAttribute attr = (NSLayoutAttribute)obj.integerValue;
//
//        if (NSLayoutAttributeWidth == attr || NSLayoutAttributeHeight == attr) { // 宽高 -> size
//
//            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.firstItem
//                                                                          attribute:attr
//                                                                          relatedBy:NSLayoutRelationEqual
//                                                                             toItem:nil
//                                                                          attribute:NSLayoutAttributeNotAnAttribute
//                                                                         multiplier:1
//                                                                           constant:c];
//            [_constraints addObject:constraint];
//
//        } else {
//
//            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.firstItem
//                                                                          attribute:attr
//                                                                          relatedBy:NSLayoutRelationEqual
//                                                                             toItem:self.firstItem.superview
//                                                                          attribute:attr
//                                                                         multiplier:1
//                                                                           constant:c];
//            [_constraints addObject:constraint];
//        }
//    }
//    return self;
//}
//
//@end


