//
//  CSTestTableCell.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSTestTableCell.h"
#import "CSKitHeader.h"

#import "CSTestTableLayout.h"
#import "CSTestTableModel.h"

#import "CSPhotoGroupView.h"
#import "CSImageBrowser.h"

#import "CSImageHelper.h"

#import "UIView+Layout.h"

@interface CSTestTableCell ()

@property (nonatomic, strong) CSLabel * userNameLabel;
@property (nonatomic, strong) CSLabel * cotentLabel;
@property (nonatomic, strong) CSLabel * timeLabel;
@property (nonatomic, strong) UIButton * allBtn;
@property (nonatomic, strong) CSControl * iconView;
@property (nonatomic, strong) NSMutableArray * imgViewArray;

@end

#define ImageSevice(str) [NSString stringWithFormat:@"http://101.201.145.44:8080/image-service/%@",str]

@implementation CSTestTableCell

-(void)setUpView{
    
    self.iconView = [CSControl new];
    self.iconView.contentMode = UIViewContentModeScaleAspectFill;
    self.iconView.clipsToBounds = YES;
    [self.containerView addSubview:self.iconView];
    
    
    self.userNameLabel = [CSLabel new];
    self.userNameLabel.opaque = YES;
    self.userNameLabel.displaysAsynchronously = YES;
    self.userNameLabel.ignoreCommonProperties = YES;
    self.userNameLabel.layer.masksToBounds = YES;
    [self.containerView addSubview:self.userNameLabel];
    
    self.cotentLabel = [CSLabel new];
    self.cotentLabel.opaque=YES;
    self.cotentLabel.displaysAsynchronously = YES;
    self.cotentLabel.ignoreCommonProperties = YES;
    [self.containerView addSubview:self.cotentLabel];
    
    self.timeLabel = [CSLabel new];
    self.timeLabel.displaysAsynchronously = YES;
    self.timeLabel.ignoreCommonProperties = YES;
    self.timeLabel.opaque=YES;
    [self.containerView addSubview:self.timeLabel];
    
    self.allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.allBtn setTitle:@"全文" forState:UIControlStateNormal];
    
    [self.allBtn setTitle:@"收起" forState:UIControlStateSelected];
    self.allBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    [self.allBtn setTitleColor:[UIColor colorWithHexString:@"68769a"]  forState:UIControlStateNormal];
    [self.allBtn setTitleColor:[UIColor colorWithHexString:@"68769a"] forState:UIControlStateSelected];
    [self.allBtn addTarget:self action:@selector(allBtnlick:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.allBtn];
    
    
    self.imgViewArray = [NSMutableArray array];
    
    for (int i = 0; i < 9; i++) {
        CSControl *imageView =[[CSControl alloc]initWithFrame:CGRectZero];
        
        imageView.hidden = YES;
        imageView.clipsToBounds = YES;
        imageView.exclusiveTouch = YES;
        imageView.layer.masksToBounds = YES;
        imageView.backgroundColor = [UIColor backColor];
        imageView.layer.contentsGravity = kCAGravityCenter;
        imageView.layer.backgroundColor = [UIColor backColor].CGColor;
        
        imageView.opaque = YES;
        imageView.layer.masksToBounds = YES;
        
        
        
        [self.containerView addSubview:imageView];
        [self.imgViewArray addObject:imageView];
    }
    
    self.lineColor = [UIColor backColor2];
    
    
    
    
    self.userNameLabel.clipsToBounds = YES;
    self.userNameLabel.exclusiveTouch = YES;
    self.userNameLabel.layer.masksToBounds = YES;
    self.userNameLabel.backgroundColor = self.backgroundColor;
    
    self.timeLabel.clipsToBounds = YES;
    self.timeLabel.exclusiveTouch = YES;
    self.timeLabel.layer.masksToBounds = YES;
    self.timeLabel.backgroundColor = self.backgroundColor;
    
    self.cotentLabel.clipsToBounds = YES;
    self.cotentLabel.exclusiveTouch = YES;
    self.cotentLabel.layer.masksToBounds = YES;
    self.cotentLabel.backgroundColor = self.backgroundColor;
    
    self.iconView.clipsToBounds = YES;
    self.iconView.exclusiveTouch = YES;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.backgroundColor = self.backgroundColor;
    
}
-(void)getlayout:(CSTestTableLayout *)layout{
    
    CSTestTableModel *feed = layout.dataModel;
    self.iconView.frame = layout.avtarFrame;
    
    self.userNameLabel.size = layout.userNameLayout.textBoundingSize;
    self.userNameLabel.textLayout = layout.userNameLayout;
    self.userNameLabel.left = self.iconView.bottom+10;
    self.userNameLabel.top = self.iconView.top+5;

    
    
    self.timeLabel.size = layout.timeLayout.textBoundingSize;
    self.timeLabel.top = self.userNameLabel.bottom+7;
    self.timeLabel.left = self.userNameLabel.left;
    self.timeLabel.textLayout = layout.timeLayout;
    
    self.cotentLabel.left = self.iconView.left;
    self.cotentLabel.top = self.iconView.bottom+10;
    self.cotentLabel.size = layout.contentLayout.textBoundingSize;
    self.cotentLabel.textLayout=layout.contentLayout;
    
    self.allBtn.frame = layout.allBtnFrame;
    self.allBtn.selected = layout.isOpen;
    
    /// 圆角头像
    [self.iconView.layer setImageWithURL:[NSURL URLWithString:ImageSevice(feed.avtar)]
                             placeholder:nil
                                 options:kNilOptions
                                 manager:[CSImageHelper avatarImageManager] // 圆角头像manager，内置圆角处理
                                progress:nil
                               transform:nil
                              completion:nil];
    
    
    
    
    
    [self _setImageViewWithLayout:layout AndImageViewArr:self.imgViewArray];
    
    
    
}

-(void)dealloc{
    CSNSLog(@"执行了.....");
    [self.userNameLabel removeFromSuperview];
    [self.cotentLabel removeFromSuperview];
    [self.timeLabel removeFromSuperview];
    [self.allBtn removeFromSuperview];
    [self.iconView removeFromSuperview];
    [self.imgViewArray removeAllObjects];
    
    
    self.userNameLabel = nil;
    self.cotentLabel = nil;
    self.timeLabel = nil;
    self.allBtn = nil;
    self.iconView = nil;
    self.imgViewArray = nil;
    
    
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








- (void)_setImageViewWithLayout:(CSTestTableLayout *)layout AndImageViewArr:(NSMutableArray<CSControl*>*)aImageViewArr{
    CSTestTableModel *feed = layout.dataModel;
    NSArray *pics = feed.imageArr;
    int picsCount = (int)pics.count;
    
    
    for (int i = 0; i < 9; i++) {
        CSControl *imageView = aImageViewArr[i];
        if (i >= picsCount) {
            [imageView.layer cancelCurrentImageRequest];
            imageView.hidden = YES;
        } else {
            
            CGRect rect = CGRectFromString(layout.imageSizeArr[i]);
            NSURL* imageURL = [NSURL URLWithString:ImageSevice(feed.imageArr[i][@"bigPath"])];
            
            imageView.frame = rect;
            imageView.hidden = NO;
            [imageView.layer removeAnimationForKey:@"contents"];
            
            @weakify(imageView);
            [imageView.layer setImageWithURL:imageURL
                                 placeholder:nil
                                     options:CSWebImageOptionAvoidSetImage | CSWebImageOptionProgressiveBlur | CSWebImageOptionSetImageWithFadeAnimation
                                  completion:^(UIImage *image, NSURL *url, CSWebImageFromType from, CSWebImageStage stage, NSError *error) {
                                      @strongify(imageView);
                                      if (!imageView) return;
                                      if (image && stage == CSWebImageStageFinished) {
                                          int width = rect.size.width;
                                          int height = rect.size.height;
                                          CGFloat scale = (height / width) / (imageView.height / imageView.width);
                                          if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                                              imageView.contentMode = UIViewContentModeScaleAspectFill;
                                              imageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                                          } else { // 高图只保留顶部
                                              imageView.contentMode = UIViewContentModeScaleAspectFill;
                                              imageView.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                                          }
                                          imageView.image = image;
                                          if (from != CSWebImageFromMemoryCacheFast) {
                                              CATransition *transition = [CATransition animation];
                                              transition.duration = 0.15;
                                              transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                                              transition.type = kCATransitionFade;
                                              [imageView.layer addAnimation:transition forKey:@"contents"];
                                          }
                                      }
                                  }];
            
            
            [self imageClick:imageView AndImages:aImageViewArr AndPicsCount:picsCount];
        }
    }
    
}

///图片点击事件
- (void)imageClick:(CSControl *)aView AndImages:(NSMutableArray<CSControl *>*)images AndPicsCount:(int)aPicsCount{
    
   
    
    @weakify(aView);
    aView.touchBlock = ^(CSControl *view, CSGestureRecognizerState state, NSSet *touches, UIEvent *event) {
        if (state == CSGestureRecognizerStateEnded) {
            
            NSMutableArray<CSPhotoGroupItem *> * tempItems = [NSMutableArray arrayWithCapacity:aPicsCount];
            
            for (NSInteger idex = 0; idex < aPicsCount; idex++) {
                CSControl *object = images[idex];
                CSPhotoGroupItem *item = [CSPhotoGroupItem new];
                item.thumbView = object;
                
                [tempItems addObject:item];
            }
   
            CSPhotoGroupView *v = [[CSPhotoGroupView alloc] initWithGroupItems:tempItems];
            
            ///这里是为了增加保存操作...弃舍UIWindow,毕竟 UIWindow 生成属性很麻烦
            UIView* vc = [[UIApplication sharedApplication].keyWindow topMostController].view;
            [v presentFromImageView:weak_aView toContainer:vc animated:YES completion:^{ }];
        }
    };
    
}



@end
