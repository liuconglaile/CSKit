//
//  CSImageBrowser.m
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSImageBrowser.h"
#import "CSImageBrowserFlowLayout.h"
#import "CSImageBrowserCell.h"
#import "CSImageBrowserButton.h"

#import "UIImage+CSImageBrowser.h"

#include "CSIndicator.h"

@interface CSImageBrowser ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate,
UIAlertViewDelegate,
CSImageItemEventDelegate>


@property (nonatomic,strong) UIImageView* screenshotImageView;
@property (nonatomic,strong) UIImageView* blurImageView;
@property (nonatomic,strong) UIImage* screenshot;
@property (nonatomic,strong) UIImage* blurImage;
@property (nonatomic,strong) CSImageBrowserFlowLayout* flowLayout;
@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UIPageControl* pageControl;
@property (nonatomic,weak) UIViewController* parentVC;
@property (nonatomic,assign,getter=isFirstShow) BOOL firstShow;
@property (nonatomic,strong) CSImageBrowserButton* button;
@property (nonatomic,copy)NSArray* imageModels;//存放图片模型的数组
@property (nonatomic,assign) NSInteger currentIndex;//当前页码
@property (nonatomic,strong) CSImageItem* currentImageItem;//当前的ImageItem

@end

#define kCellIdentifier @"LWImageBroserCellIdentifier"

@implementation CSImageBrowser

#pragma mark - ViewControllerLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.blurImageView];
    [self.view addSubview:self.screenshotImageView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageControl];
    [self.view addSubview:self.button];
    
    CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
    //    CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
    [self.collectionView setContentOffset:
     CGPointMake(self.currentIndex * screen_width+10, 0.0f) animated:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    self.blurImageView.frame = frame;
    self.screenshotImageView.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.2f animations:^{
        self.screenshotImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {}];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self _setCurrentItem];
    self.firstShow = NO;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.imageModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier
                                                                         forIndexPath:indexPath];
    cell.imageItem.firstShow = self.isFirstShow;
    cell.imageModel = [self.imageModels objectAtIndex:indexPath.row];
    cell.imageItem.eventDelegate = self;
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger index = offset / [UIScreen mainScreen].bounds.size.width;
    self.currentIndex = index;
    self.pageControl.currentPage = self.currentIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _setCurrentItem];
}

#pragma mark - LWImageItemDelegate

- (void)didClickedItemToHide {
    [self _hide];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:{
            NSMutableArray* tmpArray = [[NSMutableArray alloc]
                                        initWithArray:[self.imageModels copy]];
            [tmpArray removeObjectAtIndex:self.currentIndex];
            self.imageModels = tmpArray;
            [self _setCurrentItem];
            [self.collectionView reloadData];
        }
            break;
        default:break;
    }
}

- (void)show {
    [self.parentVC presentViewController:self animated:NO completion:^{}];
}

- (void)_hide {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    __weak typeof(self) weakSelf = self;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.currentImageItem.zoomScale != 1.0f) {
        self.currentImageItem.zoomScale = 1.0f;
    }
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         weakSelf.screenshotImageView.alpha = 1.0f;
                         if (weakSelf.isScalingToHide) {
                             weakSelf.currentImageItem.imageView.frame =
                             weakSelf.currentImageItem.imageModel.originPosition;
                         }
                         else {
                             weakSelf.currentImageItem.imageView.alpha = 0.0f;
                         }
                     } completion:^(BOOL finished) {
                         [weakSelf dismissViewControllerAnimated:NO completion:^{
                             weakSelf.imageModels = nil;
                         }];
                     }];
}

- (void)_hideNavigationBar {
    if (self.navigationController.navigationBarHidden == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self.navigationController setNavigationBarHidden:NO];
    }
}

- (void)_setCurrentItem {
    NSArray* cells = [self.collectionView visibleCells];
    if (cells.count != 0) {
        CSImageBrowserCell* cell = [cells objectAtIndex:0];
        if (self.currentImageItem != cell.imageItem) {
            self.currentImageItem = cell.imageItem;
            [self _preDownLoadImageWithIndex:self.currentIndex];
        }
    }
}

- (void)_preDownLoadImageWithIndex:(NSInteger)index {
    
    CSWebImageManager* manager = [CSWebImageManager sharedManager];
    //SDWebImageManager* manager = [SDWebImageManager sharedManager];
    if (index + 1 < self.imageModels.count) {
        CSImageBrowserModel* nextModel = [self.imageModels objectAtIndex:index + 1];
        [manager requestImageWithURL:nextModel.HDURL options:CSWebImageOptionProgressiveBlur
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
            return image;
        } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, CSWebImageFromType from, CSWebImageStage stage, NSError * _Nullable error) {
            
        }];
//        [manager loadImageWithURL:nextModel.HDURL
//                          options:0
//                         progress:nil
//                        completed:^(UIImage * _Nullable image,
//                                    NSData * _Nullable data,
//                                    NSError * _Nullable error,
//                                    SDImageCacheType cacheType,
//                                    BOOL finished,
//                                    NSURL * _Nullable imageURL) {
//                        
//                        }];
    }
    if (index - 1 >= 0) {
        CSImageBrowserModel* previousModel = [self.imageModels objectAtIndex:index - 1];
        
        [manager requestImageWithURL:previousModel.HDURL options:CSWebImageOptionProgressiveBlur
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                
                            } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                return image;
                            } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, CSWebImageFromType from, CSWebImageStage stage, NSError * _Nullable error) {
                                
                            }];
        
//        [manager loadImageWithURL:previousModel.HDURL
//                          options:0
//                         progress:nil
//                        completed:^(UIImage * _Nullable image,
//                                    NSData * _Nullable data,
//                                    NSError * _Nullable error,
//                                    SDImageCacheType cacheType,
//                                    BOOL finished,
//                                    NSURL * _Nullable imageURL) {}];
    }
}

- (void)_tapMenuButton {
    
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[self.currentImageItem.imageView.image] applicationActivities:nil];
    activity.excludedActivityTypes = @[UIActivityTypeAirDrop];
    
    // incorrect usage
    // [self.navigationController pushViewController:activity animated:YES];
    
    
    
    [self presentViewController:activity animated:YES completion:NULL];
    
    
    //    LWActionSheetView* actionSheet = [[LWActionSheetView alloc]
    //                                      initTilesArray:@[@"保存到本地",@"取消"]
    //                                      delegate:self];
    //    [actionSheet show];
}

#pragma mark - LWActionSheetViewDelegate

//- (void)lwActionSheet:(LWActionSheetView *)actionSheet didSelectedButtonWithIndex:(NSInteger)index {
//    if (index == 0) {
//        [self saveImageToPhotos:self.currentImageItem.imageView.image];
//    }
//
//}

#pragma mark - Save Photo

- (void)saveImageToPhotos:(UIImage*)savedImage {
    UIImageWriteToSavedPhotosAlbum(savedImage,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    NSString* msg = @"";
    msg = @"图片已保存到本地";
    [CSIndicator showToastMessage:msg];
}

#pragma mark - Setter & Getter

- (void)setIsShowPageControl:(BOOL)isShowPageControl {
    _isShowPageControl = isShowPageControl;
    self.pageControl.hidden = !self.isShowPageControl;
}

- (CSImageBrowserFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[CSImageBrowserFlowLayout alloc] init];
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
        _collectionView = [[UICollectionView alloc]
                           initWithFrame:CGRectMake(0,
                                                    0,
                                                    screen_width+10,
                                                    self.view.bounds.size.height)
                           collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[CSImageBrowserCell class]
            forCellWithReuseIdentifier:kCellIdentifier];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        
        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
        CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
        CGFloat kPageControlHeight  = 40.0f;
        _pageControl = [[UIPageControl alloc]
                        initWithFrame:CGRectMake(0.0f,
                                                 screen_height - kPageControlHeight - 10.0f,
                                                 screen_width,
                                                 kPageControlHeight)];
        _pageControl.numberOfPages = self.imageModels.count;
        _pageControl.currentPage = self.currentIndex;
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

- (CSImageBrowserButton *)button {
    if (!_button) {
        
        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
        CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
        
        _button = [[CSImageBrowserButton alloc] initWithFrame:CGRectMake(screen_width - 60.0f,
                                                                         screen_height - 50.0f,
                                                                         60.0f,
                                                                         40.0f)];
        [_button addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(_tapMenuButton)]];
    }
    return _button;
}

- (UIImageView *)screenshotImageView {
    if (_screenshotImageView) {
        return _screenshotImageView;
    }
    _screenshotImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _screenshotImageView.image = self.screenshot;
    return _screenshotImageView;
}

- (UIImageView *)blurImageView {
    if (_blurImageView) {
        return _blurImageView;
    }
    _blurImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _blurImageView.image = self.blurImage;
    return _blurImageView;
}

#pragma mark - Initial

- (id)initWithImageBrowserModels:(NSArray *)imageModels
                    currentIndex:(NSInteger)index {
    self  = [super init];
    if (self) {
        self.firstShow = YES;
        self.isScalingToHide = YES;
        self.parentVC = [self _getParentVC];
        self.imageModels = imageModels;
        self.currentIndex = index;
        self.screenshot = [self _screenshotFromView:[UIApplication sharedApplication].keyWindow];
        self.blurImage = [self.screenshot applyBlurWithRadius:20
                                                    tintColor:[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5f]
                                        saturationDeltaFactor:1.4
                                                    maskImage:nil];
    }
    return self;
}

#pragma mark - Private

- (UIImage *)_screenshotFromView:(UIView *)aView {
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size,NO,[UIScreen mainScreen].scale);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

- (UIViewController *)_getParentVC{
    UIViewController* result = nil;
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray* windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    
    id  nextResponder = nil;
    UIViewController* appRootVC = window.rootViewController;
    if (appRootVC.presentedViewController) {
        
        nextResponder = appRootVC.presentedViewController;
        
    }else{
        
        UIView* frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        
        UITabBarController* tabbar = (UITabBarController *)nextResponder;
        UINavigationController* nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        result=nav.childViewControllers.lastObject;
        
    } else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
        
    } else {
        
        result = nextResponder;
    }
    return result;
}


@end
