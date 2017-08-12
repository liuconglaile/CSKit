//
//  CSAnimatedImageView.m
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSAnimatedImageView.h"


#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSKitMacro.h>
#import <CSkit/CSImageDecoder.h>
#import <CSkit/CSWeakProxy.h>
#import <CSkit/UIDevice+Extended.h>
#else
#import "CSKitMacro.h"
#import "CSImageDecoder.h"
#import "CSWeakProxy.h"
#import "UIDevice+Extended.h"
#endif





#define BUFFER_SIZE (10 * 1024 * 1024) // 10MB (minimum memory buffer size)

#define LOCK(...) dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(self->_lock);

#define LOCK_VIEW(...) dispatch_semaphore_wait(view->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(view->_lock);


typedef NS_ENUM(NSUInteger, CSAnimatedImageType) {
    CSAnimatedImageTypeNone = 0,
    CSAnimatedImageTypeImage,
    CSAnimatedImageTypeHighlightedImage,
    CSAnimatedImageTypeImages,
    CSAnimatedImageTypeHighlightedImages,
};



@interface CSAnimatedImageView() {
    @package
    UIImage <CSAnimatedImage> *_curAnimatedImage;
    
    dispatch_once_t _onceToken;
    dispatch_semaphore_t _lock; ///< 锁定 _buffer(缓冲区)
    NSOperationQueue *_requestQueue; ///< 图像请求队列,串行
    
    CADisplayLink *_link; ///< 自动收报机(自动监听器)用于改变帧
    NSTimeInterval _time; ///< 最后一帧后的时间
    
    UIImage *_curFrame; ///< 当前帧显示的图片
    NSUInteger _curIndex; ///< 当前帧索引 (from 0)
    NSUInteger _totalFrameCount; ///< 总帧数
    
    BOOL _loopEnd; ///< 循环是否结束.
    NSUInteger _curLoop; ///< 当前循环计数 (from 0)
    NSUInteger _totalLoop; ///< 总循环数,0表示无穷大
    
    NSMutableDictionary *_buffer; ///< 帧缓冲区
    BOOL _bufferMiss; ///< whether miss frame on last opportunity
    NSUInteger _maxBufferCount; ///< 最大缓冲区数
    NSInteger _incrBufferCount; ///< 当前允许的缓冲区计数(将逐步增加)
    
    CGRect _curContentsRect;
    BOOL _curImageHasContentsRect; ///< 图像已经实现 "animatedImageContentsRectAtIndex:"
}
@property (nonatomic, readwrite) BOOL currentIsPlayingAnimation;
- (void)calcMaxBufferCount;
@end







///MARK: ===================================================
///MARK: 图像提取操作
///MARK: ===================================================
@interface _CSAnimatedImageViewFetchOperation : NSOperation
@property (nonatomic, weak) CSAnimatedImageView *view;
@property (nonatomic, assign) NSUInteger nextIndex;
@property (nonatomic, strong) UIImage <CSAnimatedImage> *curImage;
@end


@implementation _CSAnimatedImageViewFetchOperation
- (void)main {
    __strong CSAnimatedImageView *view = _view;
    if (!view) return;
    if ([self isCancelled]) return;
    view->_incrBufferCount++;
    if (view->_incrBufferCount == 0) [view calcMaxBufferCount];
    if (view->_incrBufferCount > (NSInteger)view->_maxBufferCount) {
        view->_incrBufferCount = view->_maxBufferCount;
    }
    NSUInteger idx = _nextIndex;
    NSUInteger max = view->_incrBufferCount < 1 ? 1 : view->_incrBufferCount;
    NSUInteger total = view->_totalFrameCount;
    view = nil;
    
    for (int i = 0; i < max; i++, idx++) {
        @autoreleasepool {
            if (idx >= total) idx = 0;
            if ([self isCancelled]) break;
            __strong CSAnimatedImageView *view = _view;
            if (!view) break;
            LOCK_VIEW(BOOL miss = (view->_buffer[@(idx)] == nil));
            if (miss) {
                UIImage *img = [_curImage animatedImageFrameAtIndex:idx];
                
                ///MARK:CSImageCoder
                //img = img.imageByDecoded;
                if ([self isCancelled]) break;
                LOCK_VIEW(view->_buffer[@(idx)] = img ? img : [NSNull null]);
                view = nil;
            }
        }
    }
}
@end





@implementation CSAnimatedImageView

- (instancetype)init {
    self = [super init];
    _runloopMode = NSRunLoopCommonModes;
    _autoPlayAnimatedImage = YES;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _runloopMode = NSRunLoopCommonModes;
    _autoPlayAnimatedImage = YES;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    _runloopMode = NSRunLoopCommonModes;
    _autoPlayAnimatedImage = YES;
    self.frame = (CGRect) {CGPointZero, image.size };
    self.image = image;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super init];
    _runloopMode = NSRunLoopCommonModes;
    _autoPlayAnimatedImage = YES;
    CGSize size = image ? image.size : highlightedImage.size;
    self.frame = (CGRect) {CGPointZero, size };
    self.image = image;
    self.highlightedImage = highlightedImage;
    return self;
}

// 初始化动画参数.
- (void)resetAnimated {
    dispatch_once(&_onceToken, ^{
        _lock = dispatch_semaphore_create(1);
        _buffer = [NSMutableDictionary new];
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 1;
        _link = [CADisplayLink displayLinkWithTarget:[CSWeakProxy proxyWithTarget:self] selector:@selector(step:)];
        if (_runloopMode) {
            [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:_runloopMode];
        }
        _link.paused = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    });
    
    [_requestQueue cancelAllOperations];
    LOCK(
         if (_buffer.count) {
             NSMutableDictionary *holder = _buffer;
             _buffer = [NSMutableDictionary new];
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                 ///捕捉字典全局队列,在后台释放这些图像,以避免阻塞UI线程.
                 [holder class];
             });
         }
         );
    _link.paused = YES;
    _time = 0;
    if (_curIndex != 0) {
        [self willChangeValueForKey:@"currentAnimatedImageIndex"];
        _curIndex = 0;
        [self didChangeValueForKey:@"currentAnimatedImageIndex"];
    }
    _curAnimatedImage = nil;
    _curFrame = nil;
    _curLoop = 0;
    _totalLoop = 0;
    _totalFrameCount = 1;
    _loopEnd = NO;
    _bufferMiss = NO;
    _incrBufferCount = 0;
}

- (void)setImage:(UIImage *)image {
    if (self.image == image) return;
    [self setImage:image withType:CSAnimatedImageTypeImage];
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    if (self.highlightedImage == highlightedImage) return;
    [self setImage:highlightedImage withType:CSAnimatedImageTypeHighlightedImage];
}

- (void)setAnimationImages:(NSArray *)animationImages {
    if (self.animationImages == animationImages) return;
    [self setImage:animationImages withType:CSAnimatedImageTypeImages];
}

- (void)setHighlightedAnimationImages:(NSArray *)highlightedAnimationImages {
    if (self.highlightedAnimationImages == highlightedAnimationImages) return;
    [self setImage:highlightedAnimationImages withType:CSAnimatedImageTypeHighlightedImages];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (_link) [self resetAnimated];
    [self imageChanged];
}

- (id)imageForType:(CSAnimatedImageType)type {
    switch (type) {
        case CSAnimatedImageTypeNone: return nil;
        case CSAnimatedImageTypeImage: return self.image;
        case CSAnimatedImageTypeHighlightedImage: return self.highlightedImage;
        case CSAnimatedImageTypeImages: return self.animationImages;
        case CSAnimatedImageTypeHighlightedImages: return self.highlightedAnimationImages;
    }
    return nil;
}

- (CSAnimatedImageType)currentImageType {
    CSAnimatedImageType curType = CSAnimatedImageTypeNone;
    if (self.highlighted) {
        if (self.highlightedAnimationImages.count) curType = CSAnimatedImageTypeHighlightedImages;
        else if (self.highlightedImage) curType = CSAnimatedImageTypeHighlightedImage;
    }
    if (curType == CSAnimatedImageTypeNone) {
        if (self.animationImages.count) curType = CSAnimatedImageTypeImages;
        else if (self.image) curType = CSAnimatedImageTypeImage;
    }
    return curType;
}

- (void)setImage:(id)image withType:(CSAnimatedImageType)type {
    [self stopAnimating];
    if (_link) [self resetAnimated];
    _curFrame = nil;
    switch (type) {
        case CSAnimatedImageTypeNone: break;
        case CSAnimatedImageTypeImage: super.image = image; break;
        case CSAnimatedImageTypeHighlightedImage: super.highlightedImage = image; break;
        case CSAnimatedImageTypeImages: super.animationImages = image; break;
        case CSAnimatedImageTypeHighlightedImages: super.highlightedAnimationImages = image; break;
    }
    [self imageChanged];
}

- (void)imageChanged {
    CSAnimatedImageType newType = [self currentImageType];
    id newVisibleImage = [self imageForType:newType];
    NSUInteger newImageFrameCount = 0;
    BOOL hasContentsRect = NO;
    if ([newVisibleImage isKindOfClass:[UIImage class]] &&
        [newVisibleImage conformsToProtocol:@protocol(CSAnimatedImage)]) {
        newImageFrameCount = ((UIImage<CSAnimatedImage> *) newVisibleImage).animatedImageFrameCount;
        if (newImageFrameCount > 1) {
            hasContentsRect = [((UIImage<CSAnimatedImage> *) newVisibleImage) respondsToSelector:@selector(animatedImageContentsRectAtIndex:)];
        }
    }
    if (!hasContentsRect && _curImageHasContentsRect) {
        if (!CGRectEqualToRect(self.layer.contentsRect, CGRectMake(0, 0, 1, 1)) ) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            [CATransaction commit];
        }
    }
    _curImageHasContentsRect = hasContentsRect;
    if (hasContentsRect) {
        CGRect rect = [((UIImage<CSAnimatedImage> *) newVisibleImage) animatedImageContentsRectAtIndex:0];
        [self setContentsRect:rect forImage:newVisibleImage];
    }
    
    if (newImageFrameCount > 1) {
        [self resetAnimated];
        _curAnimatedImage = newVisibleImage;
        _curFrame = newVisibleImage;
        _totalLoop = _curAnimatedImage.animatedImageLoopCount;
        _totalFrameCount = _curAnimatedImage.animatedImageFrameCount;
        [self calcMaxBufferCount];
    }
    [self setNeedsDisplay];
    [self didMoved];
}

// 动态调整当前内存的缓冲区大小.
- (void)calcMaxBufferCount {
    int64_t bytes = (int64_t)_curAnimatedImage.animatedImageBytesPerFrame;
    if (bytes == 0) bytes = 1024;
    
    int64_t total = [UIDevice currentDevice].memoryTotal;
    int64_t free = [UIDevice currentDevice].memoryFree;
    int64_t max = MIN(total * 0.2, free * 0.6);
    max = MAX(max, BUFFER_SIZE);
    if (_maxBufferSize) max = max > _maxBufferSize ? _maxBufferSize : max;
    double maxBufferCount = (double)max / (double)bytes;
    maxBufferCount = CS_CLAMP(maxBufferCount, 1, 512);
    _maxBufferCount = maxBufferCount;
}

- (void)dealloc {
    [_requestQueue cancelAllOperations];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_link invalidate];
}

- (BOOL)isAnimating {
    return self.currentIsPlayingAnimation;
}

- (void)stopAnimating {
    [super stopAnimating];
    [_requestQueue cancelAllOperations];
    _link.paused = YES;
    self.currentIsPlayingAnimation = NO;
}

- (void)startAnimating {
    CSAnimatedImageType type = [self currentImageType];
    if (type == CSAnimatedImageTypeImages || type == CSAnimatedImageTypeHighlightedImages) {
        NSArray *images = [self imageForType:type];
        if (images.count > 0) {
            [super startAnimating];
            self.currentIsPlayingAnimation = YES;
        }
    } else {
        if (_curAnimatedImage && _link.paused) {
            _curLoop = 0;
            _loopEnd = NO;
            _link.paused = NO;
            self.currentIsPlayingAnimation = YES;
        }
    }
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    [_requestQueue cancelAllOperations];
    [_requestQueue addOperationWithBlock: ^{
        _incrBufferCount = -60 - (int)(arc4random() % 120); // 约1〜3秒长出来...
        NSNumber *next = @((_curIndex + 1) % _totalFrameCount);
        LOCK(
             NSArray * keys = _buffer.allKeys;
             for (NSNumber * key in keys) {
                 if (![key isEqualToNumber:next]) { // 保持下一帧平滑动画
                     [_buffer removeObjectForKey:key];
                 }
             }
             )//LOCK
    }];
}

- (void)didEnterBackground:(NSNotification *)notification {
    [_requestQueue cancelAllOperations];
    NSNumber *next = @((_curIndex + 1) % _totalFrameCount);
    LOCK(
         NSArray * keys = _buffer.allKeys;
         for (NSNumber * key in keys) {
             if (![key isEqualToNumber:next]) { // 保持下一帧平滑动画
                 [_buffer removeObjectForKey:key];
             }
         }
         )//LOCK
}

- (void)step:(CADisplayLink *)link {
    UIImage <CSAnimatedImage> *image = _curAnimatedImage;
    NSMutableDictionary *buffer = _buffer;
    UIImage *bufferedImage = nil;
    NSUInteger nextIndex = (_curIndex + 1) % _totalFrameCount;
    BOOL bufferIsFull = NO;
    
    if (!image) return;
    if (_loopEnd) { // 视图将保留在最后一帧
        [self stopAnimating];
        return;
    }
    
    NSTimeInterval delay = 0;
    if (!_bufferMiss) {
        _time += link.duration;
        delay = [image animatedImageDurationAtIndex:_curIndex];
        if (_time < delay) return;
        _time -= delay;
        if (nextIndex == 0) {
            _curLoop++;
            if (_curLoop >= _totalLoop && _totalLoop != 0) {
                _loopEnd = YES;
                [self stopAnimating];
                [self.layer setNeedsDisplay]; // 让系统在runloop休眠之前调用'displayLayer:'
                return; // 停在最后一帧
            }
        }
        delay = [image animatedImageDurationAtIndex:nextIndex];
        if (_time > delay) _time = delay; // 不要过度跳帧
    }
    LOCK(
         bufferedImage = buffer[@(nextIndex)];
         if (bufferedImage) {
             if ((int)_incrBufferCount < _totalFrameCount) {
                 [buffer removeObjectForKey:@(nextIndex)];
             }
             [self willChangeValueForKey:@"currentAnimatedImageIndex"];
             _curIndex = nextIndex;
             [self didChangeValueForKey:@"currentAnimatedImageIndex"];
             _curFrame = bufferedImage == (id)[NSNull null] ? nil : bufferedImage;
             if (_curImageHasContentsRect) {
                 _curContentsRect = [image animatedImageContentsRectAtIndex:_curIndex];
                 [self setContentsRect:_curContentsRect forImage:_curFrame];
             }
             nextIndex = (_curIndex + 1) % _totalFrameCount;
             _bufferMiss = NO;
             if (buffer.count == _totalFrameCount) {
                 bufferIsFull = YES;
             }
         } else {
             _bufferMiss = YES;
         }
         )//LOCK
    
    if (!_bufferMiss) {
        [self.layer setNeedsDisplay]; // 让系统在runloop休眠之前调用'displayLayer:'
    }
    
    if (!bufferIsFull && _requestQueue.operationCount == 0) { // 如果一些工作没有完成,等待下一次机会
        _CSAnimatedImageViewFetchOperation *operation = [_CSAnimatedImageViewFetchOperation new];
        operation.view = self;
        operation.nextIndex = nextIndex;
        operation.curImage = image;
        [_requestQueue addOperation:operation];
    }
}

- (void)displayLayer:(CALayer *)layer {
    if (_curFrame) {
        layer.contents = (__bridge id)_curFrame.CGImage;
    }
}

- (void)setContentsRect:(CGRect)rect forImage:(UIImage *)image{
    CGRect layerRect = CGRectMake(0, 0, 1, 1);
    if (image) {
        CGSize imageSize = image.size;
        if (imageSize.width > 0.01 && imageSize.height > 0.01) {
            layerRect.origin.x = rect.origin.x / imageSize.width;
            layerRect.origin.y = rect.origin.y / imageSize.height;
            layerRect.size.width = rect.size.width / imageSize.width;
            layerRect.size.height = rect.size.height / imageSize.height;
            layerRect = CGRectIntersection(layerRect, CGRectMake(0, 0, 1, 1));
            if (CGRectIsNull(layerRect) || CGRectIsEmpty(layerRect)) {
                layerRect = CGRectMake(0, 0, 1, 1);
            }
        }
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.contentsRect = layerRect;
    [CATransaction commit];
}

- (void)didMoved {
    if (self.autoPlayAnimatedImage) {
        if(self.superview && self.window) {
            [self startAnimating];
        } else {
            [self stopAnimating];
        }
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self didMoved];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self didMoved];
}

- (void)setCurrentAnimatedImageIndex:(NSUInteger)currentAnimatedImageIndex {
    if (!_curAnimatedImage) return;
    if (currentAnimatedImageIndex >= _curAnimatedImage.animatedImageFrameCount) return;
    if (_curIndex == currentAnimatedImageIndex) return;
    
    dispatch_async_on_main_queue(^{
        LOCK(
             [_requestQueue cancelAllOperations];
             [_buffer removeAllObjects];
             [self willChangeValueForKey:@"currentAnimatedImageIndex"];
             _curIndex = currentAnimatedImageIndex;
             [self didChangeValueForKey:@"currentAnimatedImageIndex"];
             _curFrame = [_curAnimatedImage animatedImageFrameAtIndex:_curIndex];
             if (_curImageHasContentsRect) {
                 _curContentsRect = [_curAnimatedImage animatedImageContentsRectAtIndex:_curIndex];
             }
             _time = 0;
             _loopEnd = NO;
             _bufferMiss = NO;
             [self.layer setNeedsDisplay];
             )//LOCK
    });
}

- (NSUInteger)currentAnimatedImageIndex {
    return _curIndex;
}

- (void)setRunloopMode:(NSString *)runloopMode {
    if ([_runloopMode isEqual:runloopMode]) return;
    if (_link) {
        if (_runloopMode) {
            [_link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:_runloopMode];
        }
        if (runloopMode.length) {
            [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:runloopMode];
        }
    }
    _runloopMode = runloopMode.copy;
}

#pragma mark - Overrice NSObject(NSKeyValueObservingCustomization)

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"currentAnimatedImageIndex"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    _runloopMode = [aDecoder decodeObjectForKey:@"runloopMode"];
    if (_runloopMode.length == 0) _runloopMode = NSRunLoopCommonModes;
    if ([aDecoder containsValueForKey:@"autoPlayAnimatedImage"]) {
        _autoPlayAnimatedImage = [aDecoder decodeBoolForKey:@"autoPlayAnimatedImage"];
    } else {
        _autoPlayAnimatedImage = YES;
    }
    
    UIImage *image = [aDecoder decodeObjectForKey:@"CSAnimatedImage"];
    UIImage *highlightedImage = [aDecoder decodeObjectForKey:@"CSHighlightedAnimatedImage"];
    if (image) {
        self.image = image;
        [self setImage:image withType:CSAnimatedImageTypeImage];
    }
    if (highlightedImage) {
        self.highlightedImage = highlightedImage;
        [self setImage:highlightedImage withType:CSAnimatedImageTypeHighlightedImage];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_runloopMode forKey:@"runloopMode"];
    [aCoder encodeBool:_autoPlayAnimatedImage forKey:@"autoPlayAnimatedImage"];
    
    BOOL ani, multi;
    ani = [self.image conformsToProtocol:@protocol(CSAnimatedImage)];
    multi = (ani && ((UIImage <CSAnimatedImage> *)self.image).animatedImageFrameCount > 1);
    if (multi) [aCoder encodeObject:self.image forKey:@"CSAnimatedImage"];
    
    ani = [self.highlightedImage conformsToProtocol:@protocol(CSAnimatedImage)];
    multi = (ani && ((UIImage <CSAnimatedImage> *)self.highlightedImage).animatedImageFrameCount > 1);
    if (multi) [aCoder encodeObject:self.highlightedImage forKey:@"CSHighlightedAnimatedImage"];
}

@end
