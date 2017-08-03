//
//  UIImageView+Extended.m
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIImageView+Extended.h"
#import <objc/runtime.h>
#define BETTER_LAYER_NAME @"BETTER_LAYER_NAME"
#define GOLDEN_RATIO (0.618)

#ifdef UIImageView_DEBUG
#define UIImageViewLog(format...) NSLog(format)
#else
#define UIImageViewLog(format...)
#endif

static const CGFloat FontResizingProportion = 0.42f;
static CIDetector * _faceDetector;
static CIDetector * detector;




///MARK:=================================================
///MARK: GIF播放相关
///MARK:=================================================
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
/**********************************************************************/

@interface PlayGIFManager : NSObject
@property (nonatomic, strong) CADisplayLink     *displayLink;
@property (nonatomic, strong) NSHashTable       *gifViewHashTable;
@property (nonatomic, strong) NSMapTable        *gifSourceRefMapTable;
+ (PlayGIFManager *)shared;
- (void)stopGIFView:(UIImageView *)view;
@end
@implementation PlayGIFManager
+ (PlayGIFManager *)shared{
    static PlayGIFManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PlayGIFManager alloc] init];
    });
    return _sharedInstance;
}
- (id)init{
    self = [super init];
    if (self) {
        _gifViewHashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        _gifSourceRefMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
    }
    return self;
}
- (void)play{
    for (UIImageView *imageView in _gifViewHashTable) {
        [imageView performSelector:@selector(play)];
    }
}
- (void)stopDisplayLink{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}
- (void)stopGIFView:(UIImageView *)view{
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:view]);
    if (ref) {
        [_gifSourceRefMapTable removeObjectForKey:view];
        CFRelease(ref);
    }
    [_gifViewHashTable removeObject:view];
    if (_gifViewHashTable.count<1 && !_displayLink) {
        [self stopDisplayLink];
    }
}
@end

/**********************************************************************/

static const char * kGifPathKey         = "kGifPathKey";
static const char * kGifDataKey         = "kGifDataKey";
static const char * kIndexKey           = "kIndexKey";
static const char * kFrameCountKey      = "kFrameCountKey";
static const char * kTimestampKey       = "kTimestampKey";
static const char * kPxSize             = "kPxSize";
static const char * kGifLength          = "kGifLength";
static const char * kIndexDurationKey   = "kIndexDurationKey";
///MARK:=================================================
///MARK: GIF播放相关
///MARK:=================================================



@implementation UIImageView (Extended)

///MARK:=================================================
///MARK: 其他相关
///MARK:=================================================


void hack_uiimageview_bf(){
    Method oriSetImgMethod = class_getInstanceMethod([UIImageView class], @selector(setImage:));
    Method newSetImgMethod = class_getInstanceMethod([UIImageView class], @selector(setBetterFaceImage:));
    method_exchangeImplementations(newSetImgMethod, oriSetImgMethod);
}

- (void)setBetterFaceImage:(UIImage *)image{
    [self setNeedsBetterFace:(image)? YES : NO];
    if (![self needsBetterFace]) {
        return;
    }
    
    [self faceDetect:image];
}

char nbfKey;
- (void)setNeedsBetterFace:(BOOL)needsBetterFace{
    objc_setAssociatedObject(self,
                             &nbfKey,
                             [NSNumber numberWithBool:needsBetterFace],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)needsBetterFace{
    NSNumber *associatedObject = objc_getAssociatedObject(self, &nbfKey);
    return [associatedObject boolValue];
}

char fastSpeedKey;
- (void)setFast:(BOOL)fast{
    objc_setAssociatedObject(self,
                             &fastSpeedKey,
                             [NSNumber numberWithBool:fast],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

char detectorKey;
- (void)setDetector:(CIDetector *)detector{
    objc_setAssociatedObject(self,
                             &detectorKey,
                             detector,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CIDetector *)detector{
    return objc_getAssociatedObject(self, &detectorKey);
}

- (BOOL)fast{
    NSNumber *associatedObject = objc_getAssociatedObject(self, &fastSpeedKey);
    return [associatedObject boolValue];
}

- (void)faceDetect:(UIImage *)aImage
{
    dispatch_queue_t queue = dispatch_queue_create("com.ibireme.CSKit.croath.betterface.queue", NULL);
    dispatch_async(queue, ^{
        CIImage* image = aImage.CIImage;
        if (image == nil) { // just in case the UIImage was created using a CGImage revert to the previous, slower implementation
            image = [CIImage imageWithCGImage:aImage.CGImage];
        }
        if (detector == nil) {
            NSDictionary  *opts = [NSDictionary dictionaryWithObject:[self fast] ? CIDetectorAccuracyLow : CIDetectorAccuracyHigh
                                                              forKey:CIDetectorAccuracy];
            detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                          context:nil
                                          options:opts];
        }
        
        NSArray* features = [detector featuresInImage:image];
        
        if ([features count] == 0) {
            UIImageViewLog(@"no faces");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self imageLayer] removeFromSuperlayer];
            });
        } else {
            UIImageViewLog(@"succeed %lu faces", (unsigned long)[features count]);
            [self markAfterFaceDetect:features
                                 size:CGSizeMake(CGImageGetWidth(aImage.CGImage),
                                                 CGImageGetHeight(aImage.CGImage))];
        }
    });
}

-(void)markAfterFaceDetect:(NSArray *)features size:(CGSize)size{
    CGRect fixedRect = CGRectMake(MAXFLOAT, MAXFLOAT, 0, 0);
    CGFloat rightBorder = 0, bottomBorder = 0;
    for (CIFaceFeature *f in features){
        CGRect oneRect = f.bounds;
        oneRect.origin.y = size.height - oneRect.origin.y - oneRect.size.height;
        
        fixedRect.origin.x = MIN(oneRect.origin.x, fixedRect.origin.x);
        fixedRect.origin.y = MIN(oneRect.origin.y, fixedRect.origin.y);
        
        rightBorder = MAX(oneRect.origin.x + oneRect.size.width, rightBorder);
        bottomBorder = MAX(oneRect.origin.y + oneRect.size.height, bottomBorder);
    }
    
    fixedRect.size.width = rightBorder - fixedRect.origin.x;
    fixedRect.size.height = bottomBorder - fixedRect.origin.y;
    
    CGPoint fixedCenter = CGPointMake(fixedRect.origin.x + fixedRect.size.width / 2.0,
                                      fixedRect.origin.y + fixedRect.size.height / 2.0);
    CGPoint offset = CGPointZero;
    CGSize finalSize = size;
    if (size.width / size.height > self.bounds.size.width / self.bounds.size.height) {
        //move horizonal
        finalSize.height = self.bounds.size.height;
        finalSize.width = size.width/size.height * finalSize.height;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;
        
        offset.x = fixedCenter.x - self.bounds.size.width * 0.5;
        if (offset.x < 0) {
            offset.x = 0;
        } else if (offset.x + self.bounds.size.width > finalSize.width) {
            offset.x = finalSize.width - self.bounds.size.width;
        }
        offset.x = - offset.x;
    } else {
        //move vertical
        finalSize.width = self.bounds.size.width;
        finalSize.height = size.height/size.width * finalSize.width;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;
        
        offset.y = fixedCenter.y - self.bounds.size.height * (1-GOLDEN_RATIO);
        if (offset.y < 0) {
            offset.y = 0;
        } else if (offset.y + self.bounds.size.height > finalSize.height){
            offset.y = finalSize.height = self.bounds.size.height;
        }
        offset.y = - offset.y;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CALayer *layer = [self imageLayer];
        layer.frame = CGRectMake(offset.x,
                                 offset.y,
                                 finalSize.width,
                                 finalSize.height);
        layer.contents = (id)self.image.CGImage;
    });
}

- (CALayer *)imageLayer {
    for (CALayer *layer in [self.layer sublayers]) {
        if ([[layer name] isEqualToString:BETTER_LAYER_NAME]) {
            return layer;
        }
    }
    
    CALayer *layer = [CALayer layer];
    [layer setName:BETTER_LAYER_NAME];
    layer.actions = @{@"contents": [NSNull null],
                      @"bounds": [NSNull null],
                      @"position": [NSNull null]};
    [self.layer addSublayer:layer];
    return layer;
}





+ (id)imageViewWithImageNamed:(NSString*)imageName
{
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
}
+ (id)imageViewWithFrame:(CGRect)frame
{
    return [[UIImageView alloc] initWithFrame:frame];
}
+ (id)imageViewWithStretchableImage:(NSString*)imageName Frame:(CGRect)frame
{
    UIImage *image =[UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    return imageView;
}
- (void)setImageWithStretchableImage:(NSString*)imageName
{
    UIImage *image =[UIImage imageNamed:imageName];
    self.image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
}
+ (id)imageViewWithImageArray:(NSArray *)imageArray duration:(NSTimeInterval)duration;
{
    if (imageArray && [imageArray count]<=0)
    {
        return nil;
    }
    UIImageView *imageView = [UIImageView imageViewWithImageNamed:[imageArray objectAtIndex:0]];
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger i = 0; i < imageArray.count; i++)
    {
        UIImage *image = [UIImage imageNamed:[imageArray objectAtIndex:i]];
        [images addObject:image];
    }
    [imageView setImage:[images objectAtIndex:0]];
    [imageView setAnimationImages:images];
    [imageView setAnimationDuration:duration];
    [imageView setAnimationRepeatCount:0];
    return imageView;
}
// 画水印
- (void)setImage:(UIImage *)image withWaterMark:(UIImage *)mark inRect:(CGRect)rect
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    // CGContextRef thisctx = UIGraphicsGetCurrentContext();
    // CGAffineTransform myTr = CGAffineTransformMake(1, 0, 0, -1, 0, self.height);
    // CGContextConcatCTM(thisctx, myTr);
    //CGContextDrawImage(thisctx,CGRectMake(0,0,self.width,self.height),[image CGImage]); //原图
    //CGContextDrawImage(thisctx,rect,[mask CGImage]); //水印图
    //原图
    [image drawInRect:self.bounds];
    //水印图
    [mark drawInRect:rect];
    // NSString *s = @"dfd";
    // [[UIColor redColor] set];
    // [s drawInRect:self.bounds withFont:[UIFont systemFontOfSize:15.0]];
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newPic;
}
- (void)setImage:(UIImage *)image withStringWaterMark:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    //原图
    [image drawInRect:self.bounds];
    //文字颜色
    [color set];
    // const CGFloat *colorComponents = CGColorGetComponents([color CGColor]);
    // CGContextSetRGBFillColor(context, colorComponents[0], colorComponents[1], colorComponents [2], colorComponents[3]);
    //水印文字
    if ([markString respondsToSelector:@selector(drawInRect:withAttributes:)])
    {
        [markString drawInRect:rect withAttributes:@{NSFontAttributeName:font}];
    }
    else
    {
        // pre-iOS7.0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [markString drawInRect:rect withFont:font];
#pragma clang diagnostic pop
    }
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newPic;
}
- (void)setImage:(UIImage *)image withStringWaterMark:(NSString *)markString atPoint:(CGPoint)point color:(UIColor *)color font:(UIFont *)font
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    //原图
    [image drawInRect:self.bounds];
    //文字颜色
    [color set];
    //水印文字
    
    if ([markString respondsToSelector:@selector(drawAtPoint:withAttributes:)])
    {
        [markString drawAtPoint:point withAttributes:@{NSFontAttributeName:font}];
    }
    else
    {
        // pre-iOS7.0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [markString drawAtPoint:point withFont:font];
#pragma clang diagnostic pop
    }
    
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newPic;
}



- (CGPoint)convertPointFromImage:(CGPoint)imagePoint {
    CGPoint viewPoint = imagePoint;
    
    CGSize imageSize = self.image.size;
    CGSize viewSize  = self.bounds.size;
    
    CGFloat ratioX = viewSize.width / imageSize.width;
    CGFloat ratioY = viewSize.height / imageSize.height;
    
    UIViewContentMode contentMode = self.contentMode;
    
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        {
            viewPoint.x *= ratioX;
            viewPoint.y *= ratioY;
            break;
        }
            
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill:
        {
            CGFloat scale;
            
            if (contentMode == UIViewContentModeScaleAspectFit) {
                scale = MIN(ratioX, ratioY);
            }
            else /*if (contentMode == UIViewContentModeScaleAspectFill)*/ {
                scale = MAX(ratioX, ratioY);
            }
            
            viewPoint.x *= scale;
            viewPoint.y *= scale;
            
            viewPoint.x += (viewSize.width  - imageSize.width  * scale) / 2.0f;
            viewPoint.y += (viewSize.height - imageSize.height * scale) / 2.0f;
            
            break;
        }
            
        case UIViewContentModeCenter:
        {
            viewPoint.x += viewSize.width / 2.0  - imageSize.width  / 2.0f;
            viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0f;
            
            break;
        }
            
        case UIViewContentModeTop:
        {
            viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0f;
            
            break;
        }
            
        case UIViewContentModeBottom:
        {
            viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0f;
            viewPoint.y += viewSize.height - imageSize.height;
            
            break;
        }
            
        case UIViewContentModeLeft:
        {
            viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0f;
            
            break;
        }
            
        case UIViewContentModeRight:
        {
            viewPoint.x += viewSize.width - imageSize.width;
            viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0f;
            
            break;
        }
            
        case UIViewContentModeTopRight:
        {
            viewPoint.x += viewSize.width - imageSize.width;
            
            break;
        }
            
            
        case UIViewContentModeBottomLeft:
        {
            viewPoint.y += viewSize.height - imageSize.height;
            
            break;
        }
            
            
        case UIViewContentModeBottomRight:
        {
            viewPoint.x += viewSize.width  - imageSize.width;
            viewPoint.y += viewSize.height - imageSize.height;
            
            break;
        }
            
        case UIViewContentModeTopLeft:
        default:
        {
            break;
        }
    }
    
    return viewPoint;
}

- (CGRect)convertRectFromImage:(CGRect)imageRect {
    CGPoint imageTopLeft     = imageRect.origin;
    CGPoint imageBottomRight = CGPointMake(CGRectGetMaxX(imageRect),
                                           CGRectGetMaxY(imageRect));
    
    CGPoint viewTopLeft     = [self convertPointFromImage:imageTopLeft];
    CGPoint viewBottomRight = [self convertPointFromImage:imageBottomRight];
    
    CGRect viewRect;
    viewRect.origin = viewTopLeft;
    viewRect.size   = CGSizeMake(ABS(viewBottomRight.x - viewTopLeft.x),
                                 ABS(viewBottomRight.y - viewTopLeft.y));
    
    return viewRect;
}

- (CGPoint)convertPointFromView:(CGPoint)viewPoint {
    CGPoint imagePoint = viewPoint;
    
    CGSize imageSize = self.image.size;
    CGSize viewSize  = self.bounds.size;
    
    CGFloat ratioX = viewSize.width / imageSize.width;
    CGFloat ratioY = viewSize.height / imageSize.height;
    
    UIViewContentMode contentMode = self.contentMode;
    
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        {
            imagePoint.x /= ratioX;
            imagePoint.y /= ratioY;
            break;
        }
            
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill:
        {
            CGFloat scale;
            
            if (contentMode == UIViewContentModeScaleAspectFit) {
                scale = MIN(ratioX, ratioY);
            }
            else /*if (contentMode == UIViewContentModeScaleAspectFill)*/ {
                scale = MAX(ratioX, ratioY);
            }
            
            // Remove the x or y margin added in FitMode
            imagePoint.x -= (viewSize.width  - imageSize.width  * scale) / 2.0f;
            imagePoint.y -= (viewSize.height - imageSize.height * scale) / 2.0f;
            
            imagePoint.x /= scale;
            imagePoint.y /= scale;
            
            break;
        }
            
        case UIViewContentModeCenter:
        {
            imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0f;
            imagePoint.y -= (viewSize.height - imageSize.height) / 2.0f;
            
            break;
        }
            
        case UIViewContentModeTop:
        {
            imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0f;
            
            break;
        }
            
        case UIViewContentModeBottom:
        {
            imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0f;
            imagePoint.y -= (viewSize.height - imageSize.height);
            
            break;
        }
            
        case UIViewContentModeLeft:
        {
            imagePoint.y -= (viewSize.height - imageSize.height) / 2.0f;
            
            break;
        }
            
        case UIViewContentModeRight:
        {
            imagePoint.x -= (viewSize.width - imageSize.width);
            imagePoint.y -= (viewSize.height - imageSize.height) / 2.0f;
            
            break;
        }
            
        case UIViewContentModeTopRight:
        {
            imagePoint.x -= (viewSize.width - imageSize.width);
            
            break;
        }
            
            
        case UIViewContentModeBottomLeft:
        {
            imagePoint.y -= (viewSize.height - imageSize.height);
            
            break;
        }
            
            
        case UIViewContentModeBottomRight:
        {
            imagePoint.x -= (viewSize.width - imageSize.width);
            imagePoint.y -= (viewSize.height - imageSize.height);
            
            break;
        }
            
        case UIViewContentModeTopLeft:
        default:
        {
            break;
        }
    }
    
    return imagePoint;
}

- (CGRect)convertRectFromView:(CGRect)viewRect {
    CGPoint viewTopLeft = viewRect.origin;
    CGPoint viewBottomRight = CGPointMake(CGRectGetMaxX(viewRect),
                                          CGRectGetMaxY(viewRect));
    
    CGPoint imageTopLeft = [self convertPointFromView:viewTopLeft];
    CGPoint imageBottomRight = [self convertPointFromView:viewBottomRight];
    
    CGRect imageRect;
    imageRect.origin = imageTopLeft;
    imageRect.size = CGSizeMake(ABS(imageBottomRight.x - imageTopLeft.x),
                                ABS(imageBottomRight.y - imageTopLeft.y));
    
    return imageRect;
}



- (void)setImageWithString:(NSString *)string {
    [self setImageWithString:string color:nil circular:NO textAttributes:nil];
}

- (void)setImageWithString:(NSString *)string color:(UIColor *)color {
    [self setImageWithString:string color:color circular:NO textAttributes:nil];
}

- (void)setImageWithString:(NSString *)string color:(UIColor *)color circular:(BOOL)isCircular {
    [self setImageWithString:string color:color circular:isCircular textAttributes:nil];
}

- (void)setImageWithString:(NSString *)string color:(UIColor *)color circular:(BOOL)isCircular fontName:(NSString *)fontName {
    [self setImageWithString:string color:color circular:isCircular textAttributes:@{
                                                                                     NSFontAttributeName:[self fontForFontName:fontName],
                                                                                     NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                                     }];
}

- (void)setImageWithString:(NSString *)string color:(UIColor *)color circular:(BOOL)isCircular textAttributes:(NSDictionary *)textAttributes {
    if (!textAttributes) {
        textAttributes = @{
                           NSFontAttributeName: [self fontForFontName:nil],
                           NSForegroundColorAttributeName: [UIColor whiteColor]
                           };
    }
    
    NSMutableString *displayString = [NSMutableString stringWithString:@""];
    
    NSMutableArray *words = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
    
    //
    // Get first letter of the first and last word
    //
    if ([words count]) {
        NSString *firstWord = [words firstObject];
        if ([firstWord length]) {
            // Get character range to handle emoji (emojis consist of 2 characters in sequence)
            NSRange firstLetterRange = [firstWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
            [displayString appendString:[firstWord substringWithRange:firstLetterRange]];
        }
        
        if ([words count] >= 2) {
            NSString *lastWord = [words lastObject];
            
            while ([lastWord length] == 0 && [words count] >= 2) {
                [words removeLastObject];
                lastWord = [words lastObject];
            }
            
            if ([words count] > 1) {
                // Get character range to handle emoji (emojis consist of 2 characters in sequence)
                NSRange lastLetterRange = [lastWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
                [displayString appendString:[lastWord substringWithRange:lastLetterRange]];
            }
        }
    }
    
    UIColor *backgroundColor = color ? color : [self letter_randomColor];
    
    self.image = [self imageSnapshotFromText:[displayString uppercaseString] backgroundColor:backgroundColor circular:isCircular textAttributes:textAttributes];
}

#pragma mark - Helpers

- (UIFont *)fontForFontName:(NSString *)fontName {
    
    CGFloat fontSize = CGRectGetWidth(self.bounds) * FontResizingProportion;
    if (fontName) {
        return [UIFont fontWithName:fontName size:fontSize];
    }
    else {
        return [UIFont systemFontOfSize:fontSize];
    }
    
}

- (UIColor *)letter_randomColor {
    
    float red = 0.0;
    while (red < 0.1 || red > 0.84) {
        red = drand48();
    }
    
    float green = 0.0;
    while (green < 0.1 || green > 0.84) {
        green = drand48();
    }
    
    float blue = 0.0;
    while (blue < 0.1 || blue > 0.84) {
        blue = drand48();
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (UIImage *)imageSnapshotFromText:(NSString *)text backgroundColor:(UIColor *)color circular:(BOOL)isCircular textAttributes:(NSDictionary *)textAttributes {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize size = self.bounds.size;
    if (self.contentMode == UIViewContentModeScaleToFill ||
        self.contentMode == UIViewContentModeScaleAspectFill ||
        self.contentMode == UIViewContentModeScaleAspectFit ||
        self.contentMode == UIViewContentModeRedraw)
    {
        size.width = floorf(size.width * scale) / scale;
        size.height = floorf(size.height * scale) / scale;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (isCircular) {
        //
        // Clip context to a circle
        //
        CGPathRef path = CGPathCreateWithEllipseInRect(self.bounds, NULL);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGPathRelease(path);
    }
    
    //
    // Fill background of context
    //
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    //
    // Draw text in the context
    //
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGRect bounds = self.bounds;
    
    [text drawInRect:CGRectMake(bounds.size.width/2 - textSize.width/2,
                                bounds.size.height/2 - textSize.height/2,
                                textSize.width,
                                textSize.height)
      withAttributes:textAttributes];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}


/**
 *  @brief  倒影
 */
- (void)reflect {
    CGRect frame = self.frame;
    frame.origin.y += (frame.size.height + 1);
    
    UIImageView *reflectionImageView = [[UIImageView alloc] initWithFrame:frame];
    self.clipsToBounds = TRUE;
    reflectionImageView.contentMode = self.contentMode;
    [reflectionImageView setImage:self.image];
    reflectionImageView.transform = CGAffineTransformMakeScale(1.0, -1.0);
    
    CALayer *reflectionLayer = [reflectionImageView layer];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.bounds = reflectionLayer.bounds;
    gradientLayer.position = CGPointMake(reflectionLayer.bounds.size.width / 2, reflectionLayer.bounds.size.height * 0.5);
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor clearColor] CGColor],
                            (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] CGColor], nil];
    
    gradientLayer.startPoint = CGPointMake(0.5,0.5);
    gradientLayer.endPoint = CGPointMake(0.5,1.0);
    reflectionLayer.mask = gradientLayer;
    
    [self.superview addSubview:reflectionImageView];
    
}




+ (void)initialize
{
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                       context:nil
                                       options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    
}

// based on this: http://maniacdev.com/2011/11/tutorial-easy-face-detection-with-core-image-in-ios-5/
- (void)faceAwareFill {
    // Safe check!
    if (self.image == nil) {
        return;
    }
    
    CGRect facesRect = [self rectWithFaces];
    if (facesRect.size.height + facesRect.size.width == 0)
        return;
    self.contentMode = UIViewContentModeTopLeft;
    [self scaleImageFocusingOnRect:facesRect];
}

- (CGRect) rectWithFaces {
    // Get a CIIImage
    CIImage* image = self.image.CIImage;
    
    // If now available we create one using the CGImage
    if (!image) {
        image = [CIImage imageWithCGImage:self.image.CGImage];
    }
    
    // Use the static CIDetector
    CIDetector* detector = _faceDetector;
    
    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:image];
    
    // we'll iterate through every detected face. CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected.
    CGRect totalFaceRects = CGRectMake(self.image.size.width/2.0, self.image.size.height/2.0, 0, 0);
    
    if (features.count > 0) {
        //We get the CGRect of the first detected face
        totalFaceRects = ((CIFaceFeature*)[features objectAtIndex:0]).bounds;
        
        // Now we find the minimum CGRect that holds all the faces
        for (CIFaceFeature* faceFeature in features) {
            totalFaceRects = CGRectUnion(totalFaceRects, faceFeature.bounds);
        }
    }
    
    //So now we have either a CGRect holding the center of the image or all the faces.
    return totalFaceRects;
}

- (void) scaleImageFocusingOnRect:(CGRect) facesRect {
    CGFloat multi1 = self.frame.size.width / self.image.size.width;
    CGFloat multi2 = self.frame.size.height / self.image.size.height;
    CGFloat multi = MAX(multi1, multi2);
    
    //We need to 'flip' the Y coordinate to make it match the iOS coordinate system one
    facesRect.origin.y = self.image.size.height - facesRect.origin.y - facesRect.size.height;
    
    facesRect = CGRectMake(facesRect.origin.x*multi, facesRect.origin.y*multi, facesRect.size.width*multi, facesRect.size.height*multi);
    
    CGRect imageRect = CGRectZero;
    imageRect.size.width = self.image.size.width * multi;
    imageRect.size.height = self.image.size.height * multi;
    imageRect.origin.x = MIN(0.0, MAX(-facesRect.origin.x + self.frame.size.width/2.0 - facesRect.size.width/2.0, -imageRect.size.width + self.frame.size.width));
    imageRect.origin.y = MIN(0.0, MAX(-facesRect.origin.y + self.frame.size.height/2.0 -facesRect.size.height/2.0, -imageRect.size.height + self.frame.size.height));
    
    imageRect = CGRectIntegral(imageRect);
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, YES, 2.0);
    [self.image drawInRect:imageRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.image = newImage;
    
    //This is to show the red rectangle over the faces
#ifdef DEBUGGING_FACE_AWARE_FILL
    NSInteger theRedRectangleTag = -3312;
    UIView* facesRectLine = [self viewWithTag:theRedRectangleTag];
    if (!facesRectLine) {
        facesRectLine = [[UIView alloc] initWithFrame:facesRect];
        facesRectLine.tag = theRedRectangleTag;
    }
    else {
        facesRectLine.frame = facesRect;
    }
    
    facesRectLine.backgroundColor = [UIColor clearColor];
    facesRectLine.layer.borderColor = [UIColor redColor].CGColor;
    facesRectLine.layer.borderWidth = 4.0;
    
    CGRect frame = facesRectLine.frame;
    frame.origin.x = imageRect.origin.x + frame.origin.x;
    frame.origin.y = imageRect.origin.y + frame.origin.y;
    facesRectLine.frame = frame;
    
    [self addSubview:facesRectLine];
#endif
}
///MARK:=================================================
///MARK: 其他相关
///MARK:=================================================













///MARK:=================================================
///MARK: GIF播放相关
///MARK:=================================================
@dynamic gifPath;
@dynamic gifData;
@dynamic index;
@dynamic frameCount;
@dynamic timestamp;
@dynamic indexDurations;

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(removeFromSuperview);
        SEL swizzledSelector = @selector(yfgif_removeFromSuperview);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}
-(void)yfgif_removeFromSuperview{
    [self stopGIF];
    [self yfgif_removeFromSuperview];
}

#pragma mark - ASSOCIATION

-(NSString *)gifPath{
    return objc_getAssociatedObject(self, kGifPathKey);
}
- (void)setGifPath:(NSString *)gifPath{
    objc_setAssociatedObject(self, kGifPathKey, gifPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSData *)gifData{
    return objc_getAssociatedObject(self, kGifDataKey);
}
- (void)setGifData:(NSData *)gifData{
    objc_setAssociatedObject(self, kGifDataKey, gifData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSNumber *)index{
    return objc_getAssociatedObject(self, kIndexKey);
}
- (void)setIndex:(NSNumber *)index{
    objc_setAssociatedObject(self, kIndexKey, index, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSNumber *)frameCount{
    return objc_getAssociatedObject(self, kFrameCountKey);
}
- (void)setFrameCount:(NSNumber *)frameCount{
    objc_setAssociatedObject(self, kFrameCountKey, frameCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSNumber *)timestamp{
    return objc_getAssociatedObject(self, kTimestampKey);
}
- (void)setTimestamp:(NSNumber *)timestamp{
    objc_setAssociatedObject(self, kTimestampKey, timestamp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSDictionary*)indexDurations{
    return objc_getAssociatedObject(self, kIndexDurationKey);
}
-(void)setIndexDurations:(NSDictionary*)durations{
    objc_setAssociatedObject(self, kIndexDurationKey, durations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - ACTIONS

- (void)startGIF
{
    self.timestamp = 0;
    [self startGIFWithRunLoopMode:NSDefaultRunLoopMode];
}

- (void)startGIFWithRunLoopMode:(NSString * const)runLoopMode
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[PlayGIFManager shared].gifViewHashTable containsObject:self] && (self.gifData || self.gifPath)) {
            CGImageSourceRef gifSourceRef;
            if (self.gifData) {
                gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.gifData), NULL);
            }else{
                gifSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.gifPath], NULL);
            }
            if (!gifSourceRef) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PlayGIFManager shared].gifViewHashTable addObject:self];
                [[PlayGIFManager shared].gifSourceRefMapTable setObject:(__bridge id)(gifSourceRef) forKey:self];
                self.frameCount = [NSNumber numberWithInteger:CGImageSourceGetCount(gifSourceRef)];
                CGSize pxSize = [self GIFDimensionalSize];
                objc_setAssociatedObject(self, kPxSize, [NSValue valueWithCGSize:pxSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                objc_setAssociatedObject(self, kGifLength, [self buildIndexAndReturnLength], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            });
        }
    });
    if (![PlayGIFManager shared].displayLink) {
        [PlayGIFManager shared].displayLink = [CADisplayLink displayLinkWithTarget:[PlayGIFManager shared] selector:@selector(play)];
        [[PlayGIFManager shared].displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:runLoopMode];
    }
}

-(NSNumber*)buildIndexAndReturnLength{
    
    NSMutableDictionary* d = [[NSMutableDictionary alloc] initWithCapacity:[self.frameCount integerValue]];
    float l = 0;
    for(int i = 0; i < [self.frameCount intValue]; i++){
        float durationAtIndex = [self frameDurationAtIndex:i];
        [d setObject:@(durationAtIndex) forKey:@(i)];
        l += durationAtIndex;
    }
    self.indexDurations = d;
    return @(l);
}

-(NSNumber*)gifLength{
    return objc_getAssociatedObject(self, kGifLength);
}

- (void)stopGIF{
    [[PlayGIFManager shared] stopGIFView:self];
}

- (void)play{
    self.timestamp = [NSNumber numberWithFloat:self.timestamp.floatValue+[PlayGIFManager shared].displayLink.duration];
    
    float loopT = fmodf([self.timestamp floatValue], [[self gifLength] floatValue]);
    self.index = @([self indexForDuration:loopT]);
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(ref, self.index.integerValue, NULL);
    self.layer.contents = (__bridge id)(imageRef);
    CGImageRelease(imageRef);
}

- (int) indexForDuration:(float)duration{
    
    float sum = 0;
    
    for(int i = 0; i < self.frameCount.intValue; i++){
        NSNumber* singleFrameDuration = [self.indexDurations objectForKey:@(i)];
        sum += [singleFrameDuration floatValue];
        
        if(sum >= duration) {
            return i;
        }
    }
    
    return [self.frameCount intValue] - 1;
}

- (BOOL)isGIFPlaying{
    return [[PlayGIFManager shared].gifViewHashTable containsObject:self];
}

- (CGSize) gifPixelSize{
    return [objc_getAssociatedObject(self, kPxSize) CGSizeValue];
}

- (CGImageRef) gifCreateImageForFrameAtIndex:(NSInteger)index{
    if(![self isGIFPlaying]){
        return nil;
    }
    
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
    return CGImageSourceCreateImageAtIndex(ref, index, NULL);
}

- (float)gifFrameDurationAtIndex:(size_t)index{
    return [self frameDurationAtIndex:index];
}

- (CGSize)GIFDimensionalSize{
    if(![[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]){
        return CGSizeZero;
    }
    
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(ref, 0, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    
    NSNumber* pixelWidth = (dict[(NSString*)kCGImagePropertyPixelWidth]);
    NSNumber* pixelHeight = (dict[(NSString*)kCGImagePropertyPixelHeight]);
    
    CGSize sizeAsInProperties = CGSizeMake([pixelWidth floatValue], [pixelHeight floatValue]);
    
    CFRelease(dictRef);
    
    return sizeAsInProperties;
}

- (float)frameDurationAtIndex:(size_t)index{
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(ref, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    CFRelease(dictRef);
    if (unclampedDelayTime.floatValue) {
        return unclampedDelayTime.floatValue;
    }else if (delayTime.floatValue) {
        return delayTime.floatValue;
    }else{
        return 1/24.0;
    }
}

-(NSArray*)frames{
    
    NSMutableArray* images = [NSMutableArray new];
    
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[PlayGIFManager shared].gifSourceRefMapTable objectForKey:self]);
    
    if(!ref){
        return NULL;
    }
    
    NSInteger cnt = CGImageSourceGetCount(ref);
    for(NSInteger i = 0; i < cnt; i++){
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(ref, i, NULL);
        [images addObject:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
    }
    
    return images;
}




@end







