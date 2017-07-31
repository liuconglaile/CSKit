//
//  CSProgeressHUD.h
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSProgeressHUD : UIView

+ (CSProgeressHUD *)showHUDAddedTo:(UIView *)view;
+ (void)hideAllHUDForView:(UIView *)view;

@property (nonatomic,assign) CGFloat progress;

@end
