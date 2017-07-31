//
//  CSImageBrowserCell.h
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSImageItem.h"
#import "CSImageBrowserModel.h"


@interface CSImageBrowserCell : UICollectionViewCell

@property (nonatomic,strong) CSImageBrowserModel* imageModel;
@property (nonatomic,strong) CSImageItem* imageItem;

@end
