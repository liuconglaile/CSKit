//
//  CSRootLayout.m
//  CSKit
//
//  Created by 刘聪 on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "CSRootLayout.h"
#import "CSRootModel.h"
#import "CSKit.h"

@implementation CSRootLayout

- (void)celllayout{

    CSRootModel * feed = self.dataModel;
    self.cellHeight = 0;
    
    _nameLayout = [self layout:[UIFont fontMedium:16] color:[UIColor FontColor1] width:kScreenWidth - 30 string:feed.name max:NO];
    
    
    // 这个20是布局之后的上下间距之和,切记
    self.cellHeight = _nameLayout.textBoundingSize.height+20;
}

@end
