//
//  CSImageItem.m
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSImageItem.h"
#import "CSProgeressHUD.h"
#import "CSKitHeader.h"

@interface CSImageItem ()<UIScrollViewDelegate,UIActionSheetDelegate>

@property (nonatomic,assign) CGPoint originalPoint;

@end

const CGFloat kMaximumZoomScale = 3.0f;
const CGFloat kMinimumZoomScale = 1.0f;
const CGFloat kDuration = 0.3f;

@implementation CSImageItem{
    CGFloat _yFromCenter;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.maximumZoomScale = kMaximumZoomScale;
        self.minimumZoomScale = kMinimumZoomScale;
        self.zoomScale = 1.0f;
        [self addSubview:self.imageView];
        [self setupGestures];
    }
    return self;
}

- (void)setupGestures {
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleSingleTap:)];
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer* twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(handleTwoFingerTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    twoFingerTap.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:twoFingerTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}


- (void)setImageModel:(CSImageBrowserModel *)imageModel {
    if (_imageModel != imageModel) {
        _imageModel = imageModel;
    }
    self.zoomScale = 1.0f;
    [self loadHdImage:self.isFirstShow];
}

- (void)loadHdImage:(BOOL)animated {
    if (!self.imageModel.thumbnailImage) {
        self.imageView.image = self.imageModel.placeholder;
        if (!self.imageModel.placeholder) {
            return;
        }
        self.imageView.frame = [self calculateDestinationFrameWithSize:self.imageModel.placeholder.size];
        return;
    }
    
    CGRect destinationRect = [self calculateDestinationFrameWithSize:self.imageModel.thumbnailImage.size];
    
    
    
    
    
    @weakify(self);
    CSWebImageManager* manager = [CSWebImageManager sharedManager];
    [manager requestImageWithURL:self.imageModel.HDURL options:CSWebImageOptionProgressiveBlur
                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            
                        } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                            
                            return image;
                        } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, CSWebImageFromType from, CSWebImageStage stage, NSError * _Nullable error) {
                            @strongify(self);
                            
                            //已经下载的图片
                            if (image && stage == CSWebImageStageFinished) {
                                
                                self.imageView.image = self.imageModel.thumbnailImage;
                                if (animated) {
                                    self.imageView.frame = self.imageModel.originPosition;
                                    [UIView animateWithDuration:0.18f
                                                          delay:0.0f
                                                        options:UIViewAnimationOptionCurveEaseIn
                                                     animations:^{
                                                         self.imageView.center = self.center;
                                                     } completion:^(BOOL finished) {
                                                         if (finished) {
                                                             [self downloadImageWithDestinationRect:destinationRect];
                                                         }
                                                     }];
                                } else {
                                    self.imageView.center = self.center;
                                    [self downloadImageWithDestinationRect:destinationRect];
                                }
                            }
                            //还未下载的图片
                            else{
                                
                                if (animated) {
                                    self.imageView.frame = self.imageModel.originPosition;
                                    [self.imageView setImageWithURL:self.imageModel.HDURL options:CSWebImageOptionProgressiveBlur];
                                    [UIView animateWithDuration:kDuration
                                                          delay:0.0f
                                         usingSpringWithDamping:0.7
                                          initialSpringVelocity:0.0f
                                                        options:0 animations:^{
                                                            self.imageView.frame = destinationRect;
                                                        } completion:^(BOOL finished) {
                                                            
                                                        }];
                                } else {
                                    [self.imageView setImageWithURL:self.imageModel.HDURL options:CSWebImageOptionProgressiveBlur];
                                    self.imageView.frame = destinationRect;
                                }
                            }
                            
                            
                            
                        }];
}

- (void)downloadImageWithDestinationRect:(CGRect)destinationRect {
    
    
    CSProgeressHUD* progressHUD = [CSProgeressHUD showHUDAddedTo:self];
    
    @weakify(self);
    CSWebImageManager* manager = [CSWebImageManager sharedManager];
    
    
    
    
    
    
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [manager requestImageWithURL:self.imageModel.HDURL options:CSWebImageOptionProgressiveBlur
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                progressHUD.progress = (float)receivedSize/expectedSize;
                            } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                
                                return image;
                            } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, CSWebImageFromType from, CSWebImageStage stage, NSError * _Nullable error) {
                                @strongify(self);
                                
                                //已经下载的图片
                                if (image && stage == CSWebImageStageFinished) {
                                    
                                    [CSProgeressHUD hideAllHUDForView:self];
                                    self.imageView.image = image;
                                    self.imageModel.thumbnailImage = image;
                                    if ([self.eventDelegate respondsToSelector:@selector(didFinishedDownLoadHDImage)]) {
                                        [self.eventDelegate didFinishedDownLoadHDImage];
                                    }
                                    [UIView animateWithDuration:kDuration
                                                          delay:0.0f
                                         usingSpringWithDamping:0.7
                                          initialSpringVelocity:0.0f
                                                        options:0 animations:^{
                                                            self.imageView.frame = destinationRect;
                                                        } completion:^(BOOL finished) {
                                                        }];
                                }
                            }];
    });
}


#pragma mark - Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (CGRect)calculateDestinationFrameWithSize:(CGSize)size{
    
    CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
    CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
    
    CGRect rect;
    rect = CGRectMake(0.0f,
                      (screen_height - size.height * screen_width/size.width)/2,
                      screen_width,
                      size.height * screen_width/size.width);
    if (rect.size.height > screen_height) {
        rect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    }
    self.contentSize = rect.size;
    return rect;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [scrollView setZoomScale:scale + 0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - UIGestureRecognizerHandler

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        if ([self.eventDelegate respondsToSelector:@selector(didClickedItemToHide)]) {
            [self.eventDelegate didClickedItemToHide];
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTapsRequired == 2) {
        if(self.zoomScale == 1){
            float newScale = [self zoomScale] * 2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:self]];
            [self zoomToRect:zoomRect animated:YES];
        } else {
            float newScale = [self zoomScale] / 2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:self]];
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}

- (void)handleTwoFingerTap:(UITapGestureRecognizer *)gestureRecongnizer{
    float newScale = [self zoomScale]/2;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecongnizer locationInView:self]];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width = [self frame].size.width / scale;
    zoomRect.origin.x = center.x - zoomRect.size.width / 2;
    zoomRect.origin.y = center.y - zoomRect.size.height / 2;
    return zoomRect;
}

@end
