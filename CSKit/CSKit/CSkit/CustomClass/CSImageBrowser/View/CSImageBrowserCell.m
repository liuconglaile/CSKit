//
//  CSImageBrowserCell.m
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSImageBrowserCell.h"



@implementation CSImageBrowserCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.imageItem = [[CSImageItem alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.contentView addSubview:self.imageItem];
    }
    return self;
}

- (void)setImageModel:(CSImageBrowserModel *)imageModel {
    if (_imageModel != imageModel) {
        _imageModel = imageModel;
        self.imageItem.imageModel = self.imageModel;
    }
}

@end
