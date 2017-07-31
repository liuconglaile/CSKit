//
//  UIImage+Extended.m
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIImage+Extended.h"
#import <ImageIO/ImageIO.h>
#import <Accelerate/Accelerate.h>
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

#import "UIDevice+Extended.h"
#import "NSString+Extended.h"
#import "CSKitMacro.h"
#import "NSObject+CGUtilities.h"

#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#define fromCF (__bridge id)
#else
#define toCF (CFTypeRef)
#define fromCF (id)
#endif

CSSYNTH_DUMMY_CLASS(UIImage_Extended)

static NSTimeInterval _cs_CGImageSourceGetGIFFrameDelayAtIndex(CGImageSourceRef source, size_t index) {
    NSTimeInterval delay = 0;
    CFDictionaryRef dic = CGImageSourceCopyPropertiesAtIndex(source, index, NULL);
    if (dic) {
        CFDictionaryRef dicGIF = CFDictionaryGetValue(dic, kCGImagePropertyGIFDictionary);
        if (dicGIF) {
            NSNumber *num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFUnclampedDelayTime);
            if (num.doubleValue <= __FLT_EPSILON__) {
                num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFDelayTime);
            }
            delay = num.doubleValue;
        }
        CFRelease(dic);
    }
    
    // http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
    if (delay < 0.02) delay = 0.1;
    return delay;
}


static char *kSizeRequestDataKey = "NSURL.sizeRequestData";
static char *kSizeRequestTypeKey = "NSURL.sizeRequestType";
static char *kSizeRequestCompletionKey = "NSURL.sizeRequestCompletion";
typedef uint32_t dword;


@interface NSURL (CSRemoteSize)

@property (nonatomic, strong) NSMutableData *sizeRequestData;
@property (nonatomic, strong) NSString *sizeRequestType;
@property (nonatomic, copy) CSUIImageSizeRequestCompleted sizeRequestCompletion;

@end


@implementation NSURL (CSRemoteSize)

- (void)setSizeRequestCompletion: (CSUIImageSizeRequestCompleted) block {
    objc_setAssociatedObject(self, &kSizeRequestCompletionKey, block, OBJC_ASSOCIATION_COPY);
}

- (CSUIImageSizeRequestCompleted)sizeRequestCompletion {
    return objc_getAssociatedObject(self, &kSizeRequestCompletionKey);
}

- (void)setSizeRequestData:(NSMutableData *)sizeRequestData {
    objc_setAssociatedObject(self, &kSizeRequestDataKey, sizeRequestData, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableData*)sizeRequestData {
    return objc_getAssociatedObject(self, &kSizeRequestDataKey);
}

- (void)setSizeRequestType:(NSString *)sizeRequestType {
    objc_setAssociatedObject(self, &kSizeRequestTypeKey, sizeRequestType, OBJC_ASSOCIATION_RETAIN);
}

- (NSString*)sizeRequestType {
    return objc_getAssociatedObject(self, &kSizeRequestTypeKey);
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    [self.sizeRequestData setLength: 0];    //Redirected => reset data
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data {
    NSMutableData* receivedData = self.sizeRequestData;
    
    if( !receivedData ) {
        receivedData = [NSMutableData data];
        self.sizeRequestData = receivedData;
    }
    
    [receivedData appendData: data];
    
    //Parse metadata
    const unsigned char* cString = [receivedData bytes];
    const NSInteger length = [receivedData length];
    
    const char pngSignature[8] = {137, 80, 78, 71, 13, 10, 26, 10};
    const char bmpSignature[2] = {66, 77};
    const char gifSignature[2] = {71, 73};
    const char jpgSignature[2] = {255, 216};
    
    if(!self.sizeRequestType ) {
        if( memcmp(pngSignature, cString, 8) == 0 ) {
            self.sizeRequestType = @"PNG";
        }
        else if( memcmp(bmpSignature, cString, 2) == 0 ) {
            self.sizeRequestType = @"BMP";
        }
        else if( memcmp(jpgSignature, cString, 2) == 0 ) {
            self.sizeRequestType = @"JPG";
        }
        else if( memcmp(gifSignature, cString, 2) == 0 ) {
            self.sizeRequestType = @"GIF";
        }
    }
    
    if( [self.sizeRequestType isEqualToString: @"PNG"] ) {
        char type[5];
        int offset = 8;
        
        dword chunkSize = 0;
        int chunkSizeSize = sizeof(chunkSize);
        
        if( offset+chunkSizeSize > length )
            return;
        
        memcpy(&chunkSize, cString+offset, chunkSizeSize);
        chunkSize = OSSwapInt32(chunkSize);
        offset += chunkSizeSize;
        
        if( offset + chunkSize > length )
            return;
        
        memcpy(&type, cString+offset, 4); type[4]='\0';
        offset += 4;
        
        if( strcmp(type, "IHDR") == 0 ) {   //Should always be first
            dword width = 0, height = 0;
            memcpy(&width, cString+offset, 4);
            offset += 4;
            width = OSSwapInt32(width);
            
            memcpy(&height, cString+offset, 4);
            offset += 4;
            height = OSSwapInt32(height);
            
            if( self.sizeRequestCompletion ) {
                self.sizeRequestCompletion(self, CGSizeMake(width, height));
            }
            
            self.sizeRequestCompletion = nil;
            
            [connection cancel];
        }
    }
    else if( [self.sizeRequestType isEqualToString: @"BMP"] ) {
        int offset = 18;
        dword width = 0, height = 0;
        memcpy(&width, cString+offset, 4);
        offset += 4;
        
        memcpy(&height, cString+offset, 4);
        offset += 4;
        
        if( self.sizeRequestCompletion ) {
            self.sizeRequestCompletion(self, CGSizeMake(width, height));
        }
        
        self.sizeRequestCompletion = nil;
        
        [connection cancel];
    }
    else if( [self.sizeRequestType isEqualToString: @"JPG"] ) {
        int offset = 4;
        dword block_length = cString[offset]*256 + cString[offset+1];
        
        while (offset<length) {
            offset += block_length;
            
            if( offset >= length )
                break;
            if( cString[offset] != 0xFF )
                break;
            if( cString[offset+1] == 0xC0 ||
               cString[offset+1] == 0xC1 ||
               cString[offset+1] == 0xC2 ||
               cString[offset+1] == 0xC3 ||
               cString[offset+1] == 0xC5 ||
               cString[offset+1] == 0xC6 ||
               cString[offset+1] == 0xC7 ||
               cString[offset+1] == 0xC9 ||
               cString[offset+1] == 0xCA ||
               cString[offset+1] == 0xCB ||
               cString[offset+1] == 0xCD ||
               cString[offset+1] == 0xCE ||
               cString[offset+1] == 0xCF ) {
                
                dword width = 0, height = 0;
                
                height = cString[offset+5]*256 + cString[offset+6];
                width = cString[offset+7]*256 + cString[offset+8];
                
                if( self.sizeRequestCompletion ) {
                    self.sizeRequestCompletion(self, CGSizeMake(width, height));
                }
                
                self.sizeRequestCompletion = nil;
                
                [connection cancel];
                
            }
            else {
                offset += 2;
                block_length = cString[offset]*256 + cString[offset+1];
            }
            
        }
    }
    else if( [self.sizeRequestType isEqualToString: @"GIF"] ) {
        int offset = 6;
        dword width = 0, height = 0;
        memcpy(&width, cString+offset, 2);
        offset += 2;
        
        memcpy(&height, cString+offset, 2);
        offset += 2;
        
        if( self.sizeRequestCompletion ) {
            self.sizeRequestCompletion(self, CGSizeMake(width, height));
        }
        
        self.sizeRequestCompletion = nil;
        
        [connection cancel];
    }
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error {
    if( self.sizeRequestCompletion )
        self.sizeRequestCompletion(self, CGSizeZero);
}

-(NSCachedURLResponse*)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection {
    // Basically, we failed to obtain the image size using metadata and the
    // entire image was downloaded...
    
    if(!self.sizeRequestData.length) {
        self.sizeRequestData = nil;
    }
    else {
        //Try parse to UIImage
        UIImage* image = [UIImage imageWithData: self.sizeRequestData];
        
        if( self.sizeRequestCompletion && image) {
            self.sizeRequestCompletion(self, [image size]);
            return;
        }
    }
    
    self.sizeRequestCompletion(self, CGSizeZero);
}


@end








@implementation UIImage (Extended)

+ (UIImage *)imageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFTypeRef)(data), NULL);
    if (!source) return nil;
    
    size_t count = CGImageSourceGetCount(source);
    if (count <= 1) {
        CFRelease(source);
        return [self.class imageWithData:data scale:scale];
    }
    
    NSUInteger frames[count];
    double oneFrameTime = 1 / 50.0; // 50 fps
    NSTimeInterval totalTime = 0;
    NSUInteger totalFrame = 0;
    NSUInteger gcdFrame = 0;
    for (size_t i = 0; i < count; i++) {
        NSTimeInterval delay = _cs_CGImageSourceGetGIFFrameDelayAtIndex(source, i);
        totalTime += delay;
        NSInteger frame = lrint(delay / oneFrameTime);
        if (frame < 1) frame = 1;
        frames[i] = frame;
        totalFrame += frames[i];
        if (i == 0) gcdFrame = frames[i];
        else {
            NSUInteger frame = frames[i], tmp;
            if (frame < gcdFrame) {
                tmp = frame; frame = gcdFrame; gcdFrame = tmp;
            }
            while (true) {
                tmp = frame % gcdFrame;
                if (tmp == 0) break;
                frame = gcdFrame;
                gcdFrame = tmp;
            }
        }
    }
    NSMutableArray *array = [NSMutableArray new];
    for (size_t i = 0; i < count; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!imageRef) {
            CFRelease(source);
            return nil;
        }
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        if (width == 0 || height == 0) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        // BGRA8888 (premultiplied) or BGRX8888
        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, bitmapInfo);
        CGColorSpaceRelease(space);
        if (!context) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef decoded = CGBitmapContextCreateImage(context);
        CFRelease(context);
        if (!decoded) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        UIImage *image = [UIImage imageWithCGImage:decoded scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(imageRef);
        CGImageRelease(decoded);
        if (!image) {
            CFRelease(source);
            return nil;
        }
        for (size_t j = 0, max = frames[i] / gcdFrame; j < max; j++) {
            [array addObject:image];
        }
    }
    CFRelease(source);
    UIImage *image = [self.class animatedImageWithImages:array duration:totalTime];
    return image;
}

+ (BOOL)isAnimatedGIFData:(NSData *)data {
    if (data.length < 16) return NO;
    UInt32 magic = *(UInt32 *)data.bytes;
    // http://www.w3.org/Graphics/GIF/spec-gif89a.txt
    if ((magic & 0xFFFFFF) != '\0FIG') return NO;
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFTypeRef)data, NULL);
    if (!source) return NO;
    size_t count = CGImageSourceGetCount(source);
    CFRelease(source);
    return count > 1;
}

+ (BOOL)isAnimatedGIFFile:(NSString *)path {
    if (path.length == 0) return NO;
    const char *cpath = path.UTF8String;
    FILE *fd = fopen(cpath, "rb");
    if (!fd) return NO;
    
    BOOL isGIF = NO;
    UInt32 magic = 0;
    if (fread(&magic, sizeof(UInt32), 1, fd) == 1) {
        if ((magic & 0xFFFFFF) == '\0FIG') isGIF = YES;
    }
    fclose(fd);
    return isGIF;
}

+ (UIImage *)imageWithPDF:(id)dataOrPath {
    return [self _yy_imageWithPDF:dataOrPath resize:NO size:CGSizeZero];
}

+ (UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size {
    return [self _yy_imageWithPDF:dataOrPath resize:YES size:size];
}

+ (UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size {
    if (emoji.length == 0) return nil;
    if (size < 1) return nil;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CTFontRef font = CTFontCreateWithName(CFSTR("AppleColorEmoji"), size * scale, NULL);
    if (!font) return nil;
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:emoji attributes:@{ (__bridge id)kCTFontAttributeName:(__bridge id)font, (__bridge id)kCTForegroundColorAttributeName:(__bridge id)[UIColor whiteColor].CGColor }];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, size * scale, size * scale, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFTypeRef)str);
    CGRect bounds = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseGlyphPathBounds);
    CGContextSetTextPosition(ctx, 0, -bounds.origin.y);
    CTLineDraw(line, ctx);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    
    CFRelease(font);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
    if (line)CFRelease(line);
    if (imageRef) CFRelease(imageRef);
    
    return image;
}

+ (UIImage *)_yy_imageWithPDF:(id)dataOrPath resize:(BOOL)resize size:(CGSize)size {
    CGPDFDocumentRef pdf = NULL;
    if ([dataOrPath isKindOfClass:[NSData class]]) {
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)dataOrPath);
        pdf = CGPDFDocumentCreateWithProvider(provider);
        CGDataProviderRelease(provider);
    } else if ([dataOrPath isKindOfClass:[NSString class]]) {
        pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:dataOrPath]);
    }
    if (!pdf) return nil;
    
    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
    if (!page) {
        CGPDFDocumentRelease(pdf);
        return nil;
    }
    
    CGRect pdfRect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    CGSize pdfSize = resize ? size : pdfRect.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, pdfSize.width * scale, pdfSize.height * scale, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    if (!ctx) {
        CGColorSpaceRelease(colorSpace);
        CGPDFDocumentRelease(pdf);
        return nil;
    }
    
    CGContextScaleCTM(ctx, scale, scale);
    CGContextTranslateCTM(ctx, -pdfRect.origin.x, -pdfRect.origin.y);
    CGContextDrawPDFPage(ctx, page);
    CGPDFDocumentRelease(pdf);
    
    CGImageRef image = CGBitmapContextCreateImage(ctx);
    UIImage *pdfImage = [[UIImage alloc] initWithCGImage:image scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(image);
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    return pdfImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock {
    if (!drawBlock) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    drawBlock(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)hasAlphaChannel {
    if (self.CGImage == NULL) return NO;
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage) & kCGBitmapAlphaInfoMask;
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips{
    CGRect drawRect = CSCGRectFitWithContentMode(rect, self.size, contentMode);
    if (drawRect.size.width == 0 || drawRect.size.height == 0) return;
    if (clips) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextSaveGState(context);
            CGContextAddRect(context, rect);
            CGContextClip(context);
            [self drawInRect:drawRect];
            CGContextRestoreGState(context);
        }
    } else {
        [self drawInRect:drawRect];
    }
}

- (UIImage *)imageByResizeToSize:(CGSize)size {
    if (size.width <= 0 || size.height <= 0) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    if (size.width <= 0 || size.height <= 0) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height) withContentMode:contentMode clipsToBounds:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByCropToRect:(CGRect)rect {
    rect.origin.x *= self.scale;
    rect.origin.y *= self.scale;
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    if (rect.size.width <= 0 || rect.size.height <= 0) return nil;
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}

- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color {
    CGSize size = self.size;
    size.width -= insets.left + insets.right;
    size.height -= insets.top + insets.bottom;
    if (size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(-insets.left, -insets.top, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (color) {
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CGPathAddRect(path, NULL, rect);
        CGContextAddPath(context, path);
        CGContextEOFillPath(context);
        CGPathRelease(path);
    }
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius {
    return [self imageByRoundCornerRadius:radius borderWidth:0 borderColor:nil];
}

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor {
    return [self imageByRoundCornerRadius:radius
                                  corners:UIRectCornerAllCorners
                              borderWidth:borderWidth
                              borderColor:borderColor
                           borderLineJoin:kCGLineJoinMiter];
}

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                              corners:(UIRectCorner)corners
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor
                       borderLineJoin:(CGLineJoin)borderLineJoin {
    
    if (corners != UIRectCornerAllCorners) {
        UIRectCorner tmp = 0;
        if (corners & UIRectCornerTopLeft) tmp |= UIRectCornerBottomLeft;
        if (corners & UIRectCornerTopRight) tmp |= UIRectCornerBottomRight;
        if (corners & UIRectCornerBottomLeft) tmp |= UIRectCornerTopLeft;
        if (corners & UIRectCornerBottomRight) tmp |= UIRectCornerTopRight;
        corners = tmp;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    CGFloat minSize = MIN(self.size.width, self.size.height);
    if (borderWidth < minSize / 2) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth) byRoundingCorners:corners cornerRadii:CGSizeMake(radius, borderWidth)];
        [path closePath];
        
        CGContextSaveGState(context);
        [path addClip];
        CGContextDrawImage(context, rect, self.CGImage);
        CGContextRestoreGState(context);
    }
    
    if (borderColor && borderWidth < minSize / 2 && borderWidth > 0) {
        CGFloat strokeInset = (floor(borderWidth * self.scale) + 0.5) / self.scale;
        CGRect strokeRect = CGRectInset(rect, strokeInset, strokeInset);
        CGFloat strokeRadius = radius > self.scale / 2 ? radius - self.scale / 2 : 0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:strokeRect byRoundingCorners:corners cornerRadii:CGSizeMake(strokeRadius, borderWidth)];
        [path closePath];
        
        path.lineWidth = borderWidth;
        path.lineJoinStyle = borderLineJoin;
        [borderColor setStroke];
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize {
    size_t width = (size_t)CGImageGetWidth(self.CGImage);
    size_t height = (size_t)CGImageGetHeight(self.CGImage);
    CGRect newRect = CGRectApplyAffineTransform(CGRectMake(0., 0., width, height),
                                                fitSize ? CGAffineTransformMakeRotation(radians) : CGAffineTransformIdentity);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 (size_t)newRect.size.width,
                                                 (size_t)newRect.size.height,
                                                 8,
                                                 (size_t)newRect.size.width * 4,
                                                 colorSpace,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextTranslateCTM(context, +(newRect.size.width * 0.5), +(newRect.size.height * 0.5));
    CGContextRotateCTM(context, radians);
    
    CGContextDrawImage(context, CGRectMake(-(width * 0.5), -(height * 0.5), width, height), self.CGImage);
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imgRef);
    CGContextRelease(context);
    return img;
}

- (UIImage *)_yy_flipHorizontal:(BOOL)horizontal vertical:(BOOL)vertical {
    if (!self.CGImage) return nil;
    size_t width = (size_t)CGImageGetWidth(self.CGImage);
    size_t height = (size_t)CGImageGetHeight(self.CGImage);
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
    UInt8 *data = (UInt8 *)CGBitmapContextGetData(context);
    if (!data) {
        CGContextRelease(context);
        return nil;
    }
    vImage_Buffer src = { data, height, width, bytesPerRow };
    vImage_Buffer dest = { data, height, width, bytesPerRow };
    if (vertical) {
        vImageVerticalReflect_ARGB8888(&src, &dest, kvImageBackgroundColorFill);
    }
    if (horizontal) {
        vImageHorizontalReflect_ARGB8888(&src, &dest, kvImageBackgroundColorFill);
    }
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imgRef);
    return img;
}

- (UIImage *)imageByRotateLeft90 {
    return [self imageByRotate:DegreesToRadians(90) fitSize:YES];
}

- (UIImage *)imageByRotateRight90 {
    return [self imageByRotate:DegreesToRadians(-90) fitSize:YES];
}

- (UIImage *)imageByRotate180 {
    return [self _yy_flipHorizontal:YES vertical:YES];
}

- (UIImage *)imageByFlipVertical {
    return [self _yy_flipHorizontal:NO vertical:YES];
}

- (UIImage *)imageByFlipHorizontal {
    return [self _yy_flipHorizontal:YES vertical:NO];
}

- (UIImage *)imageByTintColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    [color set];
    UIRectFill(rect);
    [self drawAtPoint:CGPointMake(0, 0) blendMode:kCGBlendModeDestinationIn alpha:1];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageByGrayscale {
    return [self imageByBlurRadius:0 tintColor:nil tintMode:0 saturation:0 maskImage:nil];
}

- (UIImage *)imageByBlurSoft {
    return [self imageByBlurRadius:60 tintColor:[UIColor colorWithWhite:0.84 alpha:0.36] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
}

- (UIImage *)imageByBlurLight {
    return [self imageByBlurRadius:60 tintColor:[UIColor colorWithWhite:1.0 alpha:0.3] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
}

- (UIImage *)imageByBlurExtraLight {
    return [self imageByBlurRadius:40 tintColor:[UIColor colorWithWhite:0.97 alpha:0.82] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
}

- (UIImage *)imageByBlurDark {
    return [self imageByBlurRadius:40 tintColor:[UIColor colorWithWhite:0.11 alpha:0.73] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
}

- (UIImage *)imageByBlurWithTint:(UIColor *)tintColor {
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    } else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self imageByBlurRadius:20 tintColor:effectColor tintMode:kCGBlendModeNormal saturation:-1.0 maskImage:nil];
}

- (UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                     tintColor:(UIColor *)tintColor
                      tintMode:(CGBlendMode)tintBlendMode
                    saturation:(CGFloat)saturation
                     maskImage:(UIImage *)maskImage {
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog(@"UIImage+YYAdd error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog(@"UIImage+YYAdd error: inputImage must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog(@"UIImage+YYAdd error: effectMaskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    // iOS7 and above can use new func.
    BOOL hasNewFunc = (long)vImageBuffer_InitWithCGImage != 0 && (long)vImageCreateCGImageFromBuffer != 0;
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturation = fabs(saturation - 1.0) > __FLT_EPSILON__;
    
    CGSize size = self.size;
    CGRect rect = { CGPointZero, size };
    CGFloat scale = self.scale;
    CGImageRef imageRef = self.CGImage;
    BOOL opaque = NO;
    
    if (!hasBlur && !hasSaturation) {
        return [self _yy_mergeImageRef:imageRef tintColor:tintColor tintBlendMode:tintBlendMode maskImage:maskImage opaque:opaque];
    }
    
    vImage_Buffer effect = { 0 }, scratch = { 0 };
    vImage_Buffer *input = NULL, *output = NULL;
    
    vImage_CGImageFormat format = {
        .bitsPerComponent = 8,
        .bitsPerPixel = 32,
        .colorSpace = NULL,
        .bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little, //requests a BGRA buffer.
        .version = 0,
        .decode = NULL,
        .renderingIntent = kCGRenderingIntentDefault
    };
    
    if (hasNewFunc) {
        vImage_Error err;
        err = vImageBuffer_InitWithCGImage(&effect, &format, NULL, imageRef, kvImagePrintDiagnosticsToConsole);
        if (err != kvImageNoError) {
            NSLog(@"UIImage+YYAdd error: vImageBuffer_InitWithCGImage returned error code %zi for inputImage: %@", err, self);
            return nil;
        }
        err = vImageBuffer_Init(&scratch, effect.height, effect.width, format.bitsPerPixel, kvImageNoFlags);
        if (err != kvImageNoError) {
            NSLog(@"UIImage+YYAdd error: vImageBuffer_Init returned error code %zi for inputImage: %@", err, self);
            return nil;
        }
    } else {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef effectCtx = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectCtx, 1.0, -1.0);
        CGContextTranslateCTM(effectCtx, 0, -size.height);
        CGContextDrawImage(effectCtx, rect, imageRef);
        effect.data     = CGBitmapContextGetData(effectCtx);
        effect.width    = CGBitmapContextGetWidth(effectCtx);
        effect.height   = CGBitmapContextGetHeight(effectCtx);
        effect.rowBytes = CGBitmapContextGetBytesPerRow(effectCtx);
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef scratchCtx = UIGraphicsGetCurrentContext();
        scratch.data     = CGBitmapContextGetData(scratchCtx);
        scratch.width    = CGBitmapContextGetWidth(scratchCtx);
        scratch.height   = CGBitmapContextGetHeight(scratchCtx);
        scratch.rowBytes = CGBitmapContextGetBytesPerRow(scratchCtx);
    }
    
    input = &effect;
    output = &scratch;
    
    if (hasBlur) {
        // A description of how to compute the box kernel width from the Gaussian
        // radius (aka standard deviation) appears in the SVG spec:
        // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
        //
        // For larger values of 's' (s >= 2.0), an approximation can be used: Three
        // successive box-blurs build a piece-wise quadratic convolution kernel, which
        // approximates the Gaussian kernel to within roughly 3%.
        //
        // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
        //
        // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
        //
        CGFloat inputRadius = blurRadius * scale;
        if (inputRadius - 2.0 < __FLT_EPSILON__) inputRadius = 2.0;
        uint32_t radius = floor((inputRadius * 3.0 * sqrt(2 * M_PI) / 4 + 0.5) / 2);
        radius |= 1; // force radius to be odd so that the three box-blur methodology works.
        int iterations;
        if (blurRadius * scale < 0.5) iterations = 1;
        else if (blurRadius * scale < 1.5) iterations = 2;
        else iterations = 3;
        NSInteger tempSize = vImageBoxConvolve_ARGB8888(input, output, NULL, 0, 0, radius, radius, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
        void *temp = malloc(tempSize);
        for (int i = 0; i < iterations; i++) {
            vImageBoxConvolve_ARGB8888(input, output, temp, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
            CS_SWAP(input, output);
        }
        free(temp);
    }
    
    
    if (hasSaturation) {
        // These values appear in the W3C Filter Effects spec:
        // https://dvcs.w3.org/hg/FXTF/raw-file/default/filters/Publish.html#grayscaleEquivalent
        CGFloat s = saturation;
        CGFloat matrixFloat[] = {
            0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
            0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
            0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
            0,                    0,                    0,                    1,
        };
        const int32_t divisor = 256;
        NSUInteger matrixSize = sizeof(matrixFloat) / sizeof(matrixFloat[0]);
        int16_t matrix[matrixSize];
        for (NSUInteger i = 0; i < matrixSize; ++i) {
            matrix[i] = (int16_t)roundf(matrixFloat[i] * divisor);
        }
        vImageMatrixMultiply_ARGB8888(input, output, matrix, divisor, NULL, NULL, kvImageNoFlags);
        CS_SWAP(input, output);
    }
    
    UIImage *outputImage = nil;
    if (hasNewFunc) {
        CGImageRef effectCGImage = NULL;
        effectCGImage = vImageCreateCGImageFromBuffer(input, &format, &_yy_cleanupBuffer, NULL, kvImageNoAllocate, NULL);
        if (effectCGImage == NULL) {
            effectCGImage = vImageCreateCGImageFromBuffer(input, &format, NULL, NULL, kvImageNoFlags, NULL);
            free(input->data);
        }
        free(output->data);
        outputImage = [self _yy_mergeImageRef:effectCGImage tintColor:tintColor tintBlendMode:tintBlendMode maskImage:maskImage opaque:opaque];
        CGImageRelease(effectCGImage);
    } else {
        CGImageRef effectCGImage;
        UIImage *effectImage;
        if (input != &effect) effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (input == &effect) effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        effectCGImage = effectImage.CGImage;
        outputImage = [self _yy_mergeImageRef:effectCGImage tintColor:tintColor tintBlendMode:tintBlendMode maskImage:maskImage opaque:opaque];
    }
    return outputImage;
}

// Helper function to handle deferred cleanup of a buffer.
static void _yy_cleanupBuffer(void *userData, void *buf_data) {
    free(buf_data);
}

// Helper function to add tint and mask.
- (UIImage *)_yy_mergeImageRef:(CGImageRef)effectCGImage
                     tintColor:(UIColor *)tintColor
                 tintBlendMode:(CGBlendMode)tintBlendMode
                     maskImage:(UIImage *)maskImage
                        opaque:(BOOL)opaque {
    BOOL hasTint = tintColor != nil && CGColorGetAlpha(tintColor.CGColor) > __FLT_EPSILON__;
    BOOL hasMask = maskImage != nil;
    CGSize size = self.size;
    CGRect rect = { CGPointZero, size };
    CGFloat scale = self.scale;
    
    if (!hasTint && !hasMask) {
        return [UIImage imageWithCGImage:effectCGImage];
    }
    
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -size.height);
    if (hasMask) {
        CGContextDrawImage(context, rect, self.CGImage);
        CGContextSaveGState(context);
        CGContextClipToMask(context, rect, maskImage.CGImage);
    }
    CGContextDrawImage(context, rect, effectCGImage);
    if (hasTint) {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, tintBlendMode);
        CGContextSetFillColorWithColor(context, tintColor.CGColor);
        CGContextFillRect(context, rect);
        CGContextRestoreGState(context);
    }
    if (hasMask) {
        CGContextRestoreGState(context);
    }
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}



///MARK:==========================================
///MARK:AnimatedGIF相关
///MARK:==========================================

static int delayCentisecondsForImageAtIndex(CGImageSourceRef const source, size_t const i) {
    int delayCentiseconds = 1;
    CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
    if (properties) {
        CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        CFRelease(properties);
        if (gifProperties) {
            CFNumberRef const number = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
            // Even though the GIF stores the delay as an integer number of centiseconds, ImageIO “helpfully” converts that to seconds for us.
            delayCentiseconds = (int)lrint([fromCF number doubleValue] * 100);
        }
    }
    return delayCentiseconds;
}

static void createImagesAndDelays(CGImageSourceRef source, size_t count, CGImageRef imagesOut[count], int delayCentisecondsOut[count]) {
    for (size_t i = 0; i < count; ++i) {
        imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
        delayCentisecondsOut[i] = delayCentisecondsForImageAtIndex(source, i);
    }
}

static int sum(size_t const count, int const *const values) {
    int theSum = 0;
    for (size_t i = 0; i < count; ++i) {
        theSum += values[i];
    }
    return theSum;
}

static int pairGCD(int a, int b) {
    if (a < b)
        return pairGCD(b, a);
    while (true) {
        int const r = a % b;
        if (r == 0)
            return b;
        a = b;
        b = r;
    }
}

static int vectorGCD(size_t const count, int const *const values) {
    int gcd = values[0];
    for (size_t i = 1; i < count; ++i) {
        // Note that after I process the first few elements of the vector, `gcd` will probably be smaller than any remaining element.  By passing the smaller value as the second argument to `pairGCD`, I avoid making it swap the arguments.
        gcd = pairGCD(values[i], gcd);
    }
    return gcd;
}

static NSArray *frameArray(size_t const count, CGImageRef const images[count], int const delayCentiseconds[count], int const totalDurationCentiseconds) {
    int const gcd = vectorGCD(count, delayCentiseconds);
    size_t const frameCount = totalDurationCentiseconds / gcd;
    UIImage *frames[frameCount];
    for (size_t i = 0, f = 0; i < count; ++i) {
        UIImage *const frame = [UIImage imageWithCGImage:images[i]];
        for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j) {
            frames[f++] = frame;
        }
    }
    return [NSArray arrayWithObjects:frames count:frameCount];
}

static void releaseImages(size_t const count, CGImageRef const images[count]) {
    for (size_t i = 0; i < count; ++i) {
        CGImageRelease(images[i]);
    }
}

static UIImage *animatedImageWithAnimatedGIFImageSource(CGImageSourceRef const source) {
    size_t const count = CGImageSourceGetCount(source);
    CGImageRef images[count];
    int delayCentiseconds[count]; // in centiseconds
    createImagesAndDelays(source, count, images, delayCentiseconds);
    int const totalDurationCentiseconds = sum(count, delayCentiseconds);
    NSArray *const frames = frameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
    UIImage *const animation = [UIImage animatedImageWithImages:frames duration:(NSTimeInterval)totalDurationCentiseconds / 100.0];
    releaseImages(count, images);
    return animation;
}

static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef source) {
    if (source) {
        UIImage *const image = animatedImageWithAnimatedGIFImageSource(source);
        CFRelease(source);
        return image;
    } else {
        return nil;
    }
}

/*
 UIImage *animation = [UIImage animatedImageWithAnimatedGIFData:theData];
 
 该GIF存储每个帧的一个单独的持续时间，以厘秒（百分之一秒）为单位。然而，一个`UIImage`仅具有单一的，总`duration`属性，这是一个浮点数.
 
 为了解决这种不匹配，我添加每个源图像（从GIF）为`animation`不同数量的次匹配GIF帧持续时间之间的比值.
 
 例如，假设的GIF包含三个帧。帧0具有持续3帧1具有持续时间9帧2具有持续15.
 我除以全部持续时间的最大公分母，它是3各自的持续时间，并添加每个帧所得的次数。
 因此`animation`将包含0帧3/3=1时，则第1帧9/3=3次，然后frame 215/3=5倍。
 我设置`animation.duration`（3+9 + 15）/100=0.27秒
 */
+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData(toCF data, NULL));
}


/*
 UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:theURL];
 
 我操作酷似`+[UIImage的animatedImageWithAnimatedGIFData：]`，但我读了`theURL`的数据。
 如果`theURL`不是`文件：`URL，你可能想叫我在后台线程或GCD的队列，以避免阻塞主线程.
 */
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithURL(toCF url, NULL));
}




+ (UIImage *)animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            duration += [self frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (UIImage *)animatedGIFNamed:(NSString *)name {
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (scale > 1.0f) {
        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];
        
        NSData *data = [NSData dataWithContentsOfFile:retinaPath];
        
        if (data) {
            return [UIImage animatedGIFWithData:data];
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            return [UIImage animatedGIFWithData:data];
        }
        
        return [UIImage imageNamed:name];
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            return [UIImage animatedGIFWithData:data];
        }
        
        return [UIImage imageNamed:name];
    }
}

- (UIImage *)animatedImageByScalingAndCroppingToSize:(CGSize)size {
    if (CGSizeEqualToSize(self.size, size) || CGSizeEqualToSize(size, CGSizeZero)) {
        return self;
    }
    
    CGSize scaledSize = size;
    CGPoint thumbnailPoint = CGPointZero;
    
    CGFloat widthFactor = size.width / self.size.width;
    CGFloat heightFactor = size.height / self.size.height;
    CGFloat scaleFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor;
    scaledSize.width = self.size.width * scaleFactor;
    scaledSize.height = self.size.height * scaleFactor;
    
    if (widthFactor > heightFactor) {
        thumbnailPoint.y = (size.height - scaledSize.height) * 0.5;
    }
    else if (widthFactor < heightFactor) {
        thumbnailPoint.x = (size.width - scaledSize.width) * 0.5;
    }
    
    NSMutableArray *scaledImages = [NSMutableArray array];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    for (UIImage *image in self.images) {
        [image drawInRect:CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledSize.width, scaledSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        [scaledImages addObject:newImage];
    }
    
    UIGraphicsEndImageContext();
    
    return [UIImage animatedImageWithImages:scaledImages duration:self.duration];
}

///MARK:==========================================
///MARK:AnimatedGIF相关
///MARK:==========================================



///MARK:==========================================
///MARK:人脸识别相关
///MARK:==========================================
#define GOLDEN_RATIO (0.618)

- (UIImage *)betterFaceImageForSize:(CGSize)size accuracy:(CSAccuracy)accurary;
{
    NSArray *features = [UIImage __faceFeaturesInImage:self accuracy:accurary];
    
    if ([features count]==0) {
        NSLog(@"no faces");
        return nil;
    } else {
        NSLog(@"succeed %lu faces", (unsigned long)[features count]);
        return [self __subImageForFaceFeatures:features size:size];
    }
}

- (UIImage *)__subImageForFaceFeatures:(NSArray *)faceFeatures size:(CGSize)size {
    CGRect fixedRect = CGRectMake(MAXFLOAT, MAXFLOAT, 0, 0);
    CGFloat rightBorder = 0, bottomBorder = 0;
    for (CIFaceFeature *faceFeature in faceFeatures){
        CGRect oneRect = faceFeature.bounds;
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
    if (size.width / size.height > self.size.width / self.size.height) {
        //move horizonal
        finalSize.height = self.size.height;
        finalSize.width = size.width/size.height * finalSize.height;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;
        
        offset.x = fixedCenter.x - self.size.width * 0.5;
        if (offset.x < 0) {
            offset.x = 0;
        } else if (offset.x + self.size.width > finalSize.width) {
            offset.x = finalSize.width - self.size.width;
        }
        offset.x = - offset.x;
    } else {
        //move vertical
        finalSize.width = self.size.width;
        finalSize.height = size.height/size.width * finalSize.width;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;
        
        offset.y = fixedCenter.y - self.size.height * (1-GOLDEN_RATIO);
        if (offset.y < 0) {
            offset.y = 0;
        } else if (offset.y + self.size.height > finalSize.height){
            offset.y = finalSize.height = self.size.height;
        }
        offset.y = - offset.y;
    }
    
    CGRect finalRect = CGRectApplyAffineTransform(CGRectMake(offset.x, offset.y, finalSize.width, finalSize.height),
                                                  CGAffineTransformMakeScale(self.scale, self.scale));
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], finalRect);
    UIImage *subImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return subImage;
}

#pragma mark - Util
+ (NSArray *)__faceFeaturesInImage:(UIImage *)image accuracy:(CSAccuracy)accurary{
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSString *accuraryStr = (accurary == CSAccuracyLow) ? CIDetectorAccuracyLow : CIDetectorAccuracyHigh;
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:@{CIDetectorAccuracy: accuraryStr}];
    
    return [detector featuresInImage:ciImage];
}

///MARK:==========================================
///MARK:人脸识别相关
///MARK:==========================================



///MARK:==========================================
///MARK:常用方法
///MARK:==========================================

+ (NSCache *)cache{
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

+ (UIImage *)iconWithFont:(UIFont *)font named:(NSString *)iconNamed withTintColor:(UIColor *)tintColor clipToBounds:(BOOL)clipToBounds forSize:(CGFloat)fontSize{
    NSString *identifier = [NSString stringWithFormat:@"%@%@%@%@%d%f", NSStringFromSelector(_cmd), font.fontName, tintColor, iconNamed, clipToBounds, fontSize];
    UIImage *image = [[self cache] objectForKey:identifier];
    if(image == nil){
        NSMutableAttributedString *ligature = [[NSMutableAttributedString alloc] initWithString:iconNamed];
        [ligature setAttributes:@{(NSString *)kCTLigatureAttributeName: @(2),
                                  (NSString *)kCTFontAttributeName: font}
                          range:NSMakeRange(0, [ligature length])];
        
        CGSize imageSize = [ligature size];
        imageSize.width = ceil(imageSize.width);
        imageSize.height = ceil(imageSize.height);
        if(!CGSizeEqualToSize(CGSizeZero, imageSize)){
            UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
            [ligature drawAtPoint:CGPointZero];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if(tintColor){
                UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextScaleCTM(context, 1, -1);
                CGContextTranslateCTM(context, 0, -imageSize.height);
                CGContextClipToMask(context, (CGRect){.size=imageSize}, [image CGImage]);
                [tintColor setFill];
                CGContextFillRect(context, (CGRect){.size=imageSize});
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if(clipToBounds && [image respondsToSelector:@selector(imageClippedToPixelBounds)]){
                image = [image performSelector:@selector(imageClippedToPixelBounds)];
            }
#pragma clang diagnostic pop
            
            [[self cache] setObject:image forKey:identifier];
        }
    }
    return image;
}

+ (UIImage *)imageWithPDFNamed:(NSString *)pdfNamed forHeight:(CGFloat)height{
    return [self imageWithPDFNamed:pdfNamed withTintColor:nil forHeight:height];
}

+ (UIImage *)imageWithPDFNamed:(NSString *)pdfNamed withTintColor:(nullable UIColor *)tintColor forHeight:(CGFloat)height{
    NSString *pdfFile = [[NSBundle mainBundle] pathForResource:pdfNamed ofType:@"pdf"];
    return [self imageWithPDFFile:pdfFile withTintColor:tintColor forSize:CGSizeMake(MAXFLOAT, height)];
}

+ (UIImage *)imageWithPDFFile:(NSString *)pdfFile withTintColor:(nullable UIColor *)tintColor forSize:(CGSize)size{
    if(!pdfFile || CGSizeEqualToSize(size, CGSizeZero)){
        return nil;
    }
    
    NSString *identifier = [NSString stringWithFormat:@"%@%@%@%@", NSStringFromSelector(_cmd), pdfFile, tintColor, NSStringFromCGSize(size)];
    UIImage *image = [[self cache] objectForKey:identifier];
    if(image){
        return image;
    }
    
    NSURL *url = [NSURL fileURLWithPath:pdfFile];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    if(!pdf){
        return nil;
    }
    
    CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);
    CGRect mediaRect = CGPDFPageGetBoxRect(page1, kCGPDFCropBox);
    
    CGSize imageSize = mediaRect.size;
    if(imageSize.height < size.height && size.height != MAXFLOAT){
        imageSize.width = round(size.height/imageSize.height*imageSize.width);
        imageSize.height = size.height;
    }
    if(imageSize.width < size.width && size.width != MAXFLOAT){
        imageSize.height = round(size.width/imageSize.width*imageSize.height);
        imageSize.width = size.width;
    }
    
    if(imageSize.height > size.height){
        imageSize.width = round(size.height/imageSize.height*imageSize.width);
        imageSize.height = size.height;
    }
    if(imageSize.width > size.width){
        imageSize.height = round(size.width/imageSize.width*imageSize.height);
        imageSize.width = size.width;
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGFloat scale = MIN(imageSize.width/mediaRect.size.width, imageSize.height/mediaRect.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -imageSize.height);
    CGContextScaleCTM(context, scale, scale);
    CGContextDrawPDFPage(context, page1);
    CGPDFDocumentRelease(pdf);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(tintColor){
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -imageSize.height);
        CGContextClipToMask(context, (CGRect){.size=imageSize}, [image CGImage]);
        [tintColor setFill];
        CGContextFillRect(context, (CGRect){.size=imageSize});
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}



+ (UIImage*)resizableHalfImage:(NSString *)name
{
    UIImage *normal = [UIImage imageNamed:name];
    
    CGFloat imageW = normal.size.width * 0.5;
    CGFloat imageH = normal.size.height * 0.5;
    return [normal resizableImageWithCapInsets:UIEdgeInsetsMake(imageH, imageW, imageH, imageW)];
}


+ (NSData *)compressImage:(UIImage *)image toMaxLength:(NSInteger)maxLength maxWidth:(NSInteger)maxWidth{
    NSAssert(maxLength > 0, @"图片的大小必须大于 0");
    NSAssert(maxWidth > 0, @"图片的最大边长必须大于 0");
    
    CGSize newSize = [self scaleImage:image withLength:maxWidth];
    UIImage *newImage = [self resizeImage:image withNewSize:newSize];
    
    CGFloat compress = 0.9f;
    NSData *data = UIImageJPEGRepresentation(newImage, compress);
    
    while (data.length > maxLength && compress > 0.01) {
        compress -= 0.02f;
        
        data = UIImageJPEGRepresentation(newImage, compress);
    }
    return data;
}

+ (UIImage *)resizeImage:(UIImage *) image withNewSize:(CGSize) newSize{
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// not thread safe
- (UIImage *)resizeImageWithSize:(CGSize)size{
    
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
    
}


//eg 640*1136 , 以宽为准，高度等比例缩放
- (UIImage *)resizeAspectImageWithSize:(CGSize)size{
    
    
    CGFloat widthScale = size.width/self.size.width; // 以宽为准
    CGFloat height = widthScale * self.size.height;//
    
    UIGraphicsBeginImageContext(CGSizeMake(size.width,height));
    [self drawInRect:CGRectMake(0, 0, size.width, height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

+ (CGSize)scaleImage:(UIImage *) image withLength:(CGFloat) imageLength{
    
    CGFloat newWidth = 0.0f;
    CGFloat newHeight = 0.0f;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    if (width > imageLength || height > imageLength){
        
        if (width > height) {
            
            newWidth = imageLength;
            newHeight = newWidth * height / width;
            
        }else if(height > width){
            
            newHeight = imageLength;
            newWidth = newHeight * width / height;
            
        }else{
            
            newWidth = imageLength;
            newHeight = imageLength;
        }
        
    }else{
        return CGSizeMake(width, height);
    }
    
    return CGSizeMake(newWidth, newHeight);
}












+ (void)requestSizeNoHeader:(NSURL*)imgURL completion:(CSUIImageSizeRequestCompleted)completion{
    
    if([imgURL isFileURL] ) {
        //Load from file stream
    }
    else {
        imgURL.sizeRequestCompletion = completion;
        
        NSURLRequest* request = [NSURLRequest requestWithURL:imgURL];
        NSURLConnection* conn = [NSURLConnection connectionWithRequest: request delegate: imgURL];
        [conn scheduleInRunLoop: [NSRunLoop mainRunLoop] forMode: NSDefaultRunLoopMode];
        [conn start];
    }
}


+ (void)requestSizeWithHeader:(NSURL*)imgURL completion:(CSUIImageSizeRequestCompleted)completion{
    //        NSURLRequest* request = [NSURLRequest requestWithURL:imgURL];
    //
    //        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *resp, NSData *d, NSError *e) {
    //            NSLog(@"respone%@", [(NSHTTPURLResponse*)resp allHeaderFields]);
    //
    //
    //        }];
}





/**
 *  @brief  根据bundle中的文件名读取图片
 *
 *  @param name 图片名
 *
 *  @return 无缓存的图片
 */
+ (UIImage *)imageWithFileName:(NSString *)name {
    return [self imageWithFileName:name inBundle:[NSBundle mainBundle]];
}
+ (UIImage *)imageWithFileName:(NSString *)name inBundle:(NSBundle*)bundle{
    NSString *extension = @"png";
    
    NSArray *components = [name componentsSeparatedByString:@"."];
    if ([components count] >= 2) {
        NSUInteger lastIndex = components.count - 1;
        extension = [components objectAtIndex:lastIndex];
        
        name = [name substringToIndex:(name.length-(extension.length+1))];
    }
    
    // 如果为Retina屏幕且存在对应图片，则返回Retina图片，否则查找普通图片
    if ([UIScreen mainScreen].scale == 2.0) {
        name = [name stringByAppendingString:@"@2x"];
        
        NSString *path = [bundle pathForResource:name ofType:extension];
        if (path != nil) {
            return [UIImage imageWithContentsOfFile:path];
        }
    }
    
    if ([UIScreen mainScreen].scale == 3.0) {
        name = [name stringByAppendingString:@"@3x"];
        
        NSString *path = [bundle pathForResource:name ofType:extension];
        if (path != nil) {
            return [UIImage imageWithContentsOfFile:path];
        }
    }
    
    NSString *path = [bundle pathForResource:name ofType:extension];
    if (path) {
        return [UIImage imageWithContentsOfFile:path];
    }
    
    return nil;
}

///MARK:==========================================
///MARK:常用方法
///MARK:==========================================




@end
