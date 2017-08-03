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



@interface CSBaseCell()


@end

@implementation CSBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //[self.contentView removeAllSubviews];
    //初始化默认控件
    [self setDefaultView];
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //[self.contentView removeAllSubviews];
        
        //初始化默认控件
        [self setDefaultView];
        
        [self setUpView];
        
    }
    return self;
    
}

-(void)setDefaultView{
    
    //去除选中状态
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.containerView = [[CSControl alloc] initWithFrame:CGRectZero];
    
    self.containerView.selectColor = UIColorHex(f0f0f0);
    self.containerView.defaultColor= UIColorHex(fafafa);
    self.containerView.showClickEffect = YES;
    
    //self.containerView.hidden = YES;
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.contentsGravity = kCAGravityCenter;
    self.containerView.layer.backgroundColor = UIColorHex(fafafa).CGColor;
    self.containerView.exclusiveTouch = YES;
    
    self.line = [self.containerView addPixLineToBottom];
    
    [self.contentView addSubview:self.containerView];
    
    @weakify(self);//切记只能弱引用,否则内存泄漏
    self.containerView.touchBlock = ^(CSControl *view, CSGestureRecognizerState state, NSSet *touches, UIEvent *event) {
        
        if (state == CSGestureRecognizerStateEnded) {
            NSIndexPath *indepath = [weak_self currnIndexPath];
            UITableView *tableView = [weak_self currnTableView];
            
            if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indepath];
            }
        }
    };
    
}
- (void)setUpView{
    
    
    
}

- (void)setLayout:(CSBaseLayoutModel *)layout{
    
    _layout = layout;
    [self getlayout:_layout];
    
}
- (void)getlayout:(CSBaseLayoutModel *)layout{
    
}
- (void)setLineColor:(UIColor *)lineColor{
    
    self.line.colors = @[(id)lineColor.CGColor,(id)lineColor.CGColor];
}
//- (void)addActionBlock:(CSCellAction)block{
//    _cellAction = block;
//    
//}
- (void)setFrame:(CGRect)frame{
    
    self.containerView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.line.frame = CGRectMake(0, self.containerView.height-CSSizeFromPixel(1),self.containerView.width , CGFloatFromPixel(1));
    
    [super setFrame:frame];
}


- (UITableView*)currnTableView{
    
    //    static UITableView *tableView = nil;
    ///这里原有的写法是错误的.
    /**
     因为对static修饰词的理解不深,导致出错.
     
     static 在修饰全局变量的时候:
     对全局变量用static声明,则该变量的作用域只限于本文件模块(全局变量的作用域仅限于当前文件,即被声明的文件中)
     例如单例模式中使用的 static
     
     
     static 在修饰局部变量的时候:
     让局部变量只初始化一次
     局部变量在程序中只有一份内存
     对局部变量用static声明,把它分配在静态存储区,该变量在整个程序执行期间不释放,其所分配的空间始终存在
     并不会改变局部变量的作用域,仅仅是改变了局部变量的生命周期(只到程序结束,这个局部变量才会销毁)
     
     
     
     所以上面的局部修饰导致只要基于这个基类的cell获取到的UITableView对象的指针指向的都是同一个内存块
     
     目前的解决办法是把tableView声明为全局成员变量
     */
    
    UITableView *tableView = nil;
    if(!tableView){
        
        for (UIView* next = [self superview]; next; next = next.superview) {
            UIResponder* nextResponder = [next nextResponder];
            if ([nextResponder isKindOfClass:[UITableView class]]) {
                tableView = (UITableView*)nextResponder;
                break;
            }
        }
    }
    return tableView;
}
- (NSIndexPath *)currnIndexPath{
    
    NSIndexPath *indexPath = [[self currnTableView] indexPathForCell:self];
    return indexPath;
}

@end
