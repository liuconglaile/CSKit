//
//  CSBaseCell.m
//  CSCategory
//
//  Created by mac on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSBaseCell.h"
#import "UIView+Extended.h"
#import "UIColor+Extended.h"
#import "NSObject+CGUtilities.h"
#import "CSBaseClickView.h"


@implementation CSBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //初始化默认控件
    [self setDefaultView];
    
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        //初始化默认控件
        [self setDefaultView];
        
        [self setUpView];
        
    }
    return self;
    
}
-(void)setDefaultView{
    
    //去除选中状态
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    _containerView =[[CSBaseClickView alloc]initWithFrame:self.bounds];
    
    _containerView.selectColor = UIColorHex(f0f0f0);
    _containerView.defaultColor= UIColorHex(fafafa);
    _containerView.showClickEffect=YES;
    self.line=[_containerView addPixLineToBottom];
    
    [self.contentView addSubview:_containerView];
    
    __block typeof(self) cell = self;
    
    [_containerView addTouchBlock:^(CSBaseClickView *view, CSBaseClickState state, NSSet *touches, UIEvent *event) {
        
        if (state == CSBaseClickStateEnded) {
            NSIndexPath *indepath= [cell currnIndexPath];
            UITableView *tableView=[cell currnTableView];
            
            if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indepath];
            }
        }
        
        
    }];
    
}
-(void)setUpView{
    
    
    
}
-(void)setLayout:(CSBaseLayoutModel *)layout{
    
    _layout = layout;
    [self getlayout:_layout];
    
}
-(void)getlayout:(CSBaseLayoutModel *)layout{
    
}
-(void)setLineColor:(UIColor *)lineColor{
    
    self.line.colors=@[(id)lineColor.CGColor,(id)lineColor.CGColor];
}
-(void)addActionBlock:(CSCellAction)block{
    self.cellAction=block;
    
}
-(void)setFrame:(CGRect)frame{
    
    _containerView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.line.frame=CGRectMake(0, _containerView.height-CSSizeFromPixel(1),_containerView.width , CGFloatFromPixel(1));
    
    [super setFrame:frame];
    
}

- (UITableView*)currnTableView{
    
    static UITableView*tableView=nil;
    
    if(!tableView){
        
        
        for (UIView* next = [self superview]; next; next = next.superview) {
            UIResponder* nextResponder = [next nextResponder];
            if ([nextResponder isKindOfClass:[UITableView class]]) {
                tableView= (UITableView*)nextResponder;
                break;
            }
        }
    }
    return tableView;
}
-(NSIndexPath *)currnIndexPath{
    
    NSIndexPath *indexPath=[[self currnTableView] indexPathForCell:self];
    return indexPath;
}

@end
