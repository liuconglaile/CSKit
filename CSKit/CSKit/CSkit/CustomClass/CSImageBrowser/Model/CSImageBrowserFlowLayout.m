//
//  CSImageBrowserFlowLayout.m
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSImageBrowserFlowLayout.h"

@implementation CSImageBrowserFlowLayout

- (instancetype)init{
    if (self = [super init]) {
        
        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
        CGFloat screen_height = [UIScreen mainScreen].bounds.size.height;
        CGFloat w = screen_width + 10.0f;
        
        self.itemSize = CGSizeMake(w, screen_height);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 0.0f;
        self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
    return self;
}

@end
