//
//  CSRootCell.m
//  CSKit
//
//  Created by 刘聪 on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSRootCell.h"
#import "CSKit.h"
#import "CSRootLayout.h"
#import "CSRootModel.h"

@interface CSRootCell()

@property (nonatomic, strong) CSLabel* nameLabel;

@end

@implementation CSRootCell

- (void)setUpView{

    self.lineColor = [UIColor backColor2];
    
    self.nameLabel = [CSLabel new];
    self.nameLabel.opaque = YES;
    self.nameLabel.displaysAsynchronously = YES;
    self.nameLabel.ignoreCommonProperties = YES;
    self.nameLabel.layer.masksToBounds = YES;
    self.nameLabel.layer.backgroundColor = [UIColor orangeRed].CGColor;
    //self.nameLabel.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:self.nameLabel];
    
}

- (void)getlayout:(CSRootLayout *)layout{

    //CSRootModel *feed = layout.dataModel;

    //CSNSLog(@"cellH:%f --- labelH:%f",layout.cellHeight,layout.nameLayout.textBoundingSize.height);
    
    self.nameLabel.size = layout.nameLayout.textBoundingSize;
    self.nameLabel.textLayout = layout.nameLayout;
    self.nameLabel.left = 15;
    self.nameLabel.top = 10;
    
    
    
    
}

- (void)setBaseTableView:(UITableView *)baseTableView{
    _baseTableView = baseTableView;
}

//- (UITableView *)currnTableView{
//    return self.baseTableView;
//}

@end
