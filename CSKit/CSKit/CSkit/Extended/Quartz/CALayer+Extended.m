//
//  CALayer+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CALayer+Extended.h"
#import "NSObject+CGUtilities.h"

CSSYNTH_DUMMY_CLASS(CALayer_Extended)

@implementation CALayer (Extended)

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSData *)snapshotPDF {
    CGRect bounds = self.bounds;
    NSMutableData *data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius {
    self.shadowColor = color.CGColor;
    self.shadowOffset = offset;
    self.shadowRadius = radius;
    self.shadowOpacity = 1;
    self.shouldRasterize = YES;
    self.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)removeAllSublayers {
    while (self.sublayers.count) {
        [self.sublayers.lastObject removeFromSuperlayer];
    }
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

- (CGPoint)center {
    return CGPointMake(self.frame.origin.x + self.frame.size.width * 0.5,
                       self.frame.origin.y + self.frame.size.height * 0.5);
}

- (void)setCenter:(CGPoint)center {
    CGRect frame = self.frame;
    frame.origin.x = center.x - frame.size.width * 0.5;
    frame.origin.y = center.y - frame.size.height * 0.5;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.frame.origin.x + self.frame.size.width * 0.5;
}

- (void)setCenterX:(CGFloat)centerX {
    CGRect frame = self.frame;
    frame.origin.x = centerX - frame.size.width * 0.5;
    self.frame = frame;
}

- (CGFloat)centerY {
    return self.frame.origin.y + self.frame.size.height * 0.5;
}

- (void)setCenterY:(CGFloat)centerY {
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

- (CGSize)frameSize {
    return self.frame.size;
}

- (void)setFrameSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)transformRotation {
    NSNumber *v = [self valueForKeyPath:@"transform.rotation"];
    return v.doubleValue;
}

- (void)setTransformRotation:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.rotation"];
}

- (CGFloat)transformRotationX {
    NSNumber *v = [self valueForKeyPath:@"transform.rotation.x"];
    return v.doubleValue;
}

- (void)setTransformRotationX:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.rotation.x"];
}

- (CGFloat)transformRotationY {
    NSNumber *v = [self valueForKeyPath:@"transform.rotation.y"];
    return v.doubleValue;
}

- (void)setTransformRotationY:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.rotation.y"];
}

- (CGFloat)transformRotationZ {
    NSNumber *v = [self valueForKeyPath:@"transform.rotation.z"];
    return v.doubleValue;
}

- (void)setTransformRotationZ:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.rotation.z"];
}

- (CGFloat)transformScaleX {
    NSNumber *v = [self valueForKeyPath:@"transform.scale.x"];
    return v.doubleValue;
}

- (void)setTransformScaleX:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.scale.x"];
}

- (CGFloat)transformScaleY {
    NSNumber *v = [self valueForKeyPath:@"transform.scale.y"];
    return v.doubleValue;
}

- (void)setTransformScaleY:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.scale.y"];
}

- (CGFloat)transformScaleZ {
    NSNumber *v = [self valueForKeyPath:@"transform.scale.z"];
    return v.doubleValue;
}

- (void)setTransformScaleZ:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.scale.z"];
}

- (CGFloat)transformScale {
    NSNumber *v = [self valueForKeyPath:@"transform.scale"];
    return v.doubleValue;
}

- (void)setTransformScale:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.scale"];
}

- (CGFloat)transformTranslationX {
    NSNumber *v = [self valueForKeyPath:@"transform.translation.x"];
    return v.doubleValue;
}

- (void)setTransformTranslationX:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.translation.x"];
}

- (CGFloat)transformTranslationY {
    NSNumber *v = [self valueForKeyPath:@"transform.translation.y"];
    return v.doubleValue;
}

- (void)setTransformTranslationY:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.translation.y"];
}

- (CGFloat)transformTranslationZ {
    NSNumber *v = [self valueForKeyPath:@"transform.translation.z"];
    return v.doubleValue;
}

- (void)setTransformTranslationZ:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.translation.z"];
}

- (CGFloat)transformDepth {
    return self.transform.m34;
}

- (void)setTransformDepth:(CGFloat)v {
    CATransform3D d = self.transform;
    d.m34 = v;
    self.transform = d;
}

- (UIViewContentMode)contentMode {
    return CSCAGravityToUIViewContentMode(self.contentsGravity);
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    self.contentsGravity = CSUIViewContentModeToCAGravity(contentMode);
}

- (void)addFadeAnimationWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve {
    if (duration <= 0) return;
    
    NSString *mediaFunction;
    switch (curve) {
        case UIViewAnimationCurveEaseInOut: {
            mediaFunction = kCAMediaTimingFunctionEaseInEaseOut;
        } break;
        case UIViewAnimationCurveEaseIn: {
            mediaFunction = kCAMediaTimingFunctionEaseIn;
        } break;
        case UIViewAnimationCurveEaseOut: {
            mediaFunction = kCAMediaTimingFunctionEaseOut;
        } break;
        case UIViewAnimationCurveLinear: {
            mediaFunction = kCAMediaTimingFunctionLinear;
        } break;
        default: {
            mediaFunction = kCAMediaTimingFunctionLinear;
        } break;
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:mediaFunction];
    transition.type = kCATransitionFade;
    [self addAnimation:transition forKey:@"cskit.fade"];
}

- (void)removePreviousFadeAnimation {
    [self removeAnimationForKey:@"cskit.fade"];
}




- (CATransition *)transitionWithAnimType:(CSTransitionAnimType)animType subType:(CSTransitionSubType)subType curve:(CSTransitionCurve)curve duration:(CGFloat)duration{
    
    NSString *key = @"transition";
    
    if([self animationForKey:key]!=nil){
        [self removeAnimationForKey:key];
    }
    
    
    CATransition *transition=[CATransition animation];
    
    //动画时长
    transition.duration=duration;
    
    //动画类型
    transition.type=[self animaTypeWithTransitionType:animType];
    
    //动画方向
    transition.subtype=[self animaSubtype:subType];
    
    //缓动函数
    transition.timingFunction=[CAMediaTimingFunction functionWithName:[self curve:curve]];
    
    //完成动画删除
    transition.removedOnCompletion = YES;
    
    [self addAnimation:transition forKey:key];
    
    return transition;
}



/*
 *  返回动画曲线
 */
- (NSString *)curve:(CSTransitionCurve)curve{
    
    //曲线数组
    NSArray *funcNames=@[kCAMediaTimingFunctionDefault,kCAMediaTimingFunctionEaseIn,kCAMediaTimingFunctionEaseInEaseOut,kCAMediaTimingFunctionEaseOut,kCAMediaTimingFunctionLinear];
    
    return [self objFromArray:funcNames index:curve isRamdom:(CSTransitionCurveRamdom == curve)];
}



/*
 *  返回动画方向
 */
- (NSString *)animaSubtype:(CSTransitionSubType)subType{
    
    //设置转场动画的方向
    NSArray *subtypes=@[kCATransitionFromTop,kCATransitionFromLeft,kCATransitionFromBottom,kCATransitionFromRight];
    
    return [self objFromArray:subtypes index:subType isRamdom:(CSTransitionSubtypesFromRamdom == subType)];
}




/*
 *  返回动画类型
 */
- (NSString *)animaTypeWithTransitionType:(CSTransitionAnimType)type{
    
    //设置转场动画的类型
    NSArray *animArray=@[@"rippleEffect",@"suckEffect",@"pageCurl",@"oglFlip",@"cube",@"reveal",@"pageUnCurl",@"push"];
    
    return [self objFromArray:animArray index:type isRamdom:(CSTransitionAnimTypeRamdom == type)];
}



/*
 *  统一从数据返回对象
 */
- (id)objFromArray:(NSArray *)array index:(NSUInteger)index isRamdom:(BOOL)isRamdom{
    
    NSUInteger count = array.count;
    
    NSUInteger i = isRamdom?arc4random_uniform((u_int32_t)count) : index;
    
    return array[i];
}


@end




