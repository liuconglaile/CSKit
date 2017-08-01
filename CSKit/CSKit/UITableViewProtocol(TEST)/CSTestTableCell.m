//
//  CSTestTableCell.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTestTableCell.h"
#import "CSKit.h"

#import "CSTestTableLayout.h"
#import "CSTestTableModel.h"

#import "CSPhotoGroupView.h"
#import "CSImageBrowser.h"


#define ImageSevice(str) [NSString stringWithFormat:@"http://101.201.145.44:8080/image-service/%@",str]

@implementation CSTestTableCell
{
    CSLabel *userNameLabel;
    CSLabel *cotentLabel;
    CSLabel *timeLabel;
    CSPictureView *iconView;
    UIButton *allBtn;
    
    NSMutableArray *imgViewArray;
    
    
    
    
}
-(void)setUpView{
    
    iconView = [CSPictureView new];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.clipsToBounds = YES;
    //iconView.backgroundColor = UIColorHex(fafafa);
    [self.containerView addSubview:iconView];
    
    
    userNameLabel = [CSLabel new];
    userNameLabel.opaque = YES;
    userNameLabel.displaysAsynchronously = YES;
    userNameLabel.ignoreCommonProperties = YES;
    userNameLabel.layer.masksToBounds = YES;
    //userNameLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
    //userNameLabel.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:userNameLabel];
    
    cotentLabel = [CSLabel new];
    cotentLabel.opaque=YES;
    cotentLabel.displaysAsynchronously = YES;
    cotentLabel.ignoreCommonProperties = YES;
    [self.containerView addSubview:cotentLabel];
    
    timeLabel = [CSLabel new];
    timeLabel.displaysAsynchronously = YES;
    timeLabel.ignoreCommonProperties = YES;
    timeLabel.opaque=YES;
    [self.containerView addSubview:timeLabel];
    
    allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [allBtn setTitle:@"全文" forState:UIControlStateNormal];
    
    [allBtn setTitle:@"收起" forState:UIControlStateSelected];
    allBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    [allBtn setTitleColor:[UIColor colorWithHexString:@"68769a"]  forState:UIControlStateNormal];
    [allBtn setTitleColor:[UIColor colorWithHexString:@"68769a"] forState:UIControlStateSelected];
    [allBtn addTarget:self action:@selector(allBtnlick:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:allBtn];
    
    
    imgViewArray = [NSMutableArray array];
    
    for (int i = 0; i<9; i++) {
        CSPictureView *imageView =[[CSPictureView alloc]initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor backColor];
        
        [self.containerView addSubview:imageView];
        [imgViewArray addObject:imageView];
    }
    
    self.lineColor = [UIColor backColor2];
}
-(void)getlayout:(CSTestTableLayout *)layout{
    
    CSTestTableModel *feed = layout.dataModel;
    iconView.frame = layout.avtarFrame;
    
    userNameLabel.size = layout.userNameLayout.textBoundingSize;
    userNameLabel.textLayout = layout.userNameLayout;
    userNameLabel.left = iconView.bottom+10;
    userNameLabel.top = iconView.top+5;
    
    timeLabel.size = layout.timeLayout.textBoundingSize;
    timeLabel.top = userNameLabel.bottom+7;
    timeLabel.left = userNameLabel.left;
    timeLabel.textLayout = layout.timeLayout;
    
    cotentLabel.left = iconView.left;
    cotentLabel.top = iconView.bottom+10;
    cotentLabel.size = layout.contentLayout.textBoundingSize;
    cotentLabel.textLayout=layout.contentLayout;
    
    allBtn.frame = layout.allBtnFrame;
    allBtn.selected = layout.isOpen;
    
    /// [iconView.layer setImageURL:[NSURL URLWithString:ImageSevice(feed.avtar)]];
    /// 圆角头像
    [iconView.layer setImageWithURL:[NSURL URLWithString:ImageSevice(feed.avtar)]
                        placeholder:nil
                            options:kNilOptions
                            manager:[CSTestTableCell avatarImageManagerWithSize:iconView.size key:@"FeedAvtar"] // 圆角头像manager，内置圆角处理
                           progress:nil
                          transform:nil
                         completion:nil];
    
    
    
    
    
    if (feed.imageArr.count > 0){
        
        //@weakify(self);
        [imgViewArray enumerateObjectsUsingBlock:^(CSPictureView *view, NSUInteger idx, BOOL * _Nonnull stop) {
            if (feed.imageArr.count-1 >= idx) {
                
                CGRect rect = CGRectFromString(layout.imageSizeArr[idx]);
                NSURL* imageURL = [NSURL URLWithString:ImageSevice(feed.imageArr[idx][@"bigPath"])];
                
                view.frame = rect;
                view.largeImageURL = imageURL;
                
                @weakify(view);
                [view.layer setImageWithURL:imageURL
                                placeholder:nil
                                    options:CSWebImageOptionAvoidSetImage //图像提取完成后,请勿将图像设置为视图.您可以手动设置图像
                                 completion:^(UIImage *image, NSURL *url, CSWebImageFromType from, CSWebImageStage stage, NSError *error) {
                                     @strongify(view);
                                     //@strongify(self);
                                     
                                     if (!view) return;
                                     if (image && stage == CSWebImageStageFinished) {
                                         
                                         view.image = image;
                                         
                                         view.contentMode = UIViewContentModeScaleAspectFill;
                                         view.clipsToBounds=YES;
                                         
                                         if (from != CSWebImageFromMemoryCacheFast) {
                                             CATransition *transition = [CATransition animation];
                                             transition.duration = 0.15;
                                             transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                                             transition.type = kCATransitionFade;
                                             [view.layer addAnimation:transition forKey:@"contents"];
                                         }
                                         
                                         
                                         ///配置图片点击事件
//                                         NSMutableArray<CSPictureView *>* tempClickImages = @[].mutableCopy;
//                                         for (CSPictureView *object in imgViewArray) {
//                                             if (!CGRectEqualToRect(object.frame, CGRectZero)) {
//                                                 [tempClickImages addObject:object];
//                                             }
//                                         }
                                         //[self imageClick:view AndImages:tempClickImages];
                                     }
                                 }];
                
                
                
            }else{
                view.frame = CGRectZero;
            }
            
        }];
    }else{
        
        [imgViewArray enumerateObjectsUsingBlock:^(CSPictureView *view, NSUInteger idx, BOOL * _Nonnull stop) {
            
            
            view.frame = CGRectZero;
            
            
        }];
    }
    
}


- (void)imageClick:(CSPictureView *)aView AndImages:(NSMutableArray<CSPictureView *>*)images{
    
    @weakify(aView);
    [aView addTouchBlock:^(CSBaseClickView *view, CSBaseClickState state, NSSet *touches, UIEvent *event) {
        @strongify(aView);
        
        
        if (state == CSBaseClickStateEnded) {
            
            NSMutableArray<CSPhotoGroupItem *> * tempItems = [NSMutableArray arrayWithCapacity:images.count];
            
            for (CSPictureView *object in images) {
                CSPhotoGroupItem *item = [CSPhotoGroupItem new];
                item.thumbView = object;
                item.largeImageURL = object.largeImageURL;
                [tempItems addObject:item];
            }
            
            
            
            
            CSPhotoGroupView *v = [[CSPhotoGroupView alloc] initWithGroupItems:tempItems];
            
            ///这里是为了增加保存操作...弃舍UIWindow,毕竟 UIWindow 生成属性很麻烦
            UIView* vc = [[UIApplication sharedApplication].keyWindow topMostController].view;
            [v presentFromImageView:aView toContainer:vc animated:YES completion:^{ }];
        }
    }];
    
}


- (void)allBtnlick:(UIButton *)butn{
    
    CSTestTableLayout *layout =(CSTestTableLayout *)self.layout;
    layout.isOpen=!layout.isOpen;
    
    [layout celllayout];
    
    UITableView *tableView = [self currnTableView];
    NSIndexPath *indexPath = [self currnIndexPath];
    [tableView beginUpdates];
    
    
    [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    
    
    if (self.cellAction) self.cellAction(@(butn.selected));
}

//这个图片处理不一定放这里，放到图片工具类
+ (CSWebImageManager *)avatarImageManagerWithSize:(CGSize)size key:(NSString *)key {
    static CSWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[UIApplication sharedApplication].cachesPath stringByAppendingPathComponent:key];
        CSImageCache *cache = [[CSImageCache alloc] initWithPath:path];
        manager = [[CSWebImageManager alloc] initWithCache:cache queue:[CSWebImageManager sharedManager].queue];
        manager.sharedTransformBlock = ^(UIImage *image, NSURL *url) {
            if (!image) return image;
            
            image=[image imageByResizeToSize:size contentMode:UIViewContentModeScaleAspectFill];
            
            return [image imageByRoundCornerRadius:size.width/2]; // a large value
        };
    });
    return manager;
}

@end
