//
//  CSImageBrowserButton.m
//  CSCategory
//
//  Created by mac on 17/5/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSImageBrowserButton.h"

@implementation CSImageBrowserButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGRect r = CGRectMake(10.0f, 10.0f, rect.size.width - 20.0f, rect.size.height - 20.0f);
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:5.0f];
    [[UIColor whiteColor] setStroke];
    [bezierPath stroke];
    [bezierPath addClip];
    
    NSMutableParagraphStyle* papragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [papragraphStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:14.0f],
                                 NSParagraphStyleAttributeName:papragraphStyle};
    NSAttributedString* string = [[NSAttributedString alloc] initWithString:@"•••"
                                                                 attributes:attributes];
    [string drawInRect:r];
}

@end
