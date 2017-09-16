//
//  CSImageBrowserModel.m
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSImageBrowserModel.h"
//#import "SDWebImageManager.h"
#import "CSWebImageManager.h"
#import "CSKitHeader.h"

@interface CSImageBrowserModel ()

@property (nonatomic,assign,readwrite) CGRect destinationFrame;
@property (nonatomic,assign,readwrite) BOOL isDownload;

@end

@implementation CSImageBrowserModel

- (id)initWithplaceholder:(UIImage *)placeholder
             thumbnailURL:(NSURL *)thumbnailURL
                    HDURL:(NSURL *)HDURL
            containerView:(UIView *)containerView
      positionInContainer:(CGRect)positionInContainer
                    index:(NSInteger)index {
    self = [super init];
    if (self) {
        
        self.placeholder = placeholder;
        self.thumbnailURL = thumbnailURL;
        self.HDURL = HDURL;
        self.index = index;
        if (containerView != nil) {
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            CGRect originRect = [containerView convertRect:positionInContainer toView:window];
            self.originPosition = originRect;
            
        }else {
            CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
            CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
            self.originPosition = CGRectMake(screen_width/2, screen_height/2, 0, 0);
        }
    }
    return self;
}

- (void)setThumbnailURL:(NSURL *)thumbnailURL {
    if (_thumbnailURL != thumbnailURL) {
        _thumbnailURL = thumbnailURL;
    }
    if (_thumbnailURL == nil) {
        return;
    }
    
    
    @weakify(self);
    CSWebImageManager* manager = [CSWebImageManager sharedManager];
    [manager requestImageWithURL:self.thumbnailURL options:CSWebImageOptionProgressiveBlur
                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                            
                        } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                            
                            return image;
                        } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, CSWebImageFromType from, CSWebImageStage stage, NSError * _Nullable error) {
                            @strongify(self);
                            
                            if (image && stage == CSWebImageStageFinished) {
                                
                                self.thumbnailImage = image;
                                self.destinationFrame =
                                [self calculateDestinationFrameWithSize:self.thumbnailImage.size
                                                                  index:self.index];
                                
                            }
                        }];
    
}


- (CGRect)calculateDestinationFrameWithSize:(CGSize)size
                                      index:(NSInteger)index {
    
    CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
    CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
    CGFloat imageBrowserWidth = screen_width+10;
    CGFloat imageBrowserHeight = screen_height;
    
    CGRect rect = CGRectMake(imageBrowserWidth * index,
                             (imageBrowserHeight - size.height * screen_width / size.width)/2,
                             screen_width,
                             size.height * screen_width / size.width);
    return rect;
}


@end
