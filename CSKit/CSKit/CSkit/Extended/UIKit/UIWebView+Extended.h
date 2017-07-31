//
//  UIWebView+Extended.h
//  CSCategory
//
//  Created by 刘聪 on 2017/7/16.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol CSJSWebViewDelegate <UIWebViewDelegate>

@optional

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext*) ctx;

@end


typedef void (^CSUIWebViewloadRequestCompleted)(UIWebView *webView);
typedef void (^CSUIWebViewloadRequestFailed)(UIWebView *webView, NSError *error);
typedef void (^CSUIWebViewloadRequestStarted)(UIWebView *webView);
typedef BOOL (^CSUIWebViewloadRequestShould)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType);


@interface UIWebView (Extended)


///MARK:==========================================
///MARK:代理转回调相关
///MARK:==========================================

/**
设置TRUE_END_REPORT为YES得到通知，只有当页面已经完全**加载，而不是在每一个单元载荷。
（还没有完全测试）。当设置为NO，它会酷似UIWebViewDelegate工作。 （默认行为）
*/
#define TRUE_END_REPORT NO

/**
加载请求，并在网页加载成功或失败加载得到通知

@param request 加载的请求链接
@param loadedBlock 加载完成后回调
@param failureBlock 加载失败回调
@return UIWebView
*/
+ (UIWebView *)loadRequest: (NSURLRequest *) request
loaded: (CSUIWebViewloadRequestCompleted) loadedBlock
failed: (CSUIWebViewloadRequestFailed) failureBlock;

/**
加载请求，并在网页加载成功或失败加载得到通知

@param htmlString 加载的请求链接字符串
@param loadedBlock 加载完成后回调
@param failureBlock 加载失败回调
@return UIWebView
*/
+(UIWebView *)loadHTMLString:(NSString *)htmlString
loaded:(CSUIWebViewloadRequestCompleted)loadedBlock
                      failed:(CSUIWebViewloadRequestFailed)failureBlock;


/**
 加载请求，并在网页加载成功，加载失败，或启动加载得到通知。另外，设置一定的页是否应该被加载.
 
 @param request 加载的请求链接
 @param loadedBlock 加载完成后回调
 @param failureBlock 加载失败回调
 @param loadStartedBlock 加载开始时回调
 @param shouldLoadBlock 回调块确定一个特定的页面是否应该被加载
 @return UIWebView
 */
+ (UIWebView *)loadRequest: (NSURLRequest *) request
                    loaded: (CSUIWebViewloadRequestCompleted) loadedBlock
                    failed: (CSUIWebViewloadRequestFailed) failureBlock
               loadStarted: (CSUIWebViewloadRequestStarted) loadStartedBlock
                shouldLoad: (CSUIWebViewloadRequestShould) shouldLoadBlock;


/**
 加载请求，并在网页加载成功，加载失败，或启动加载得到通知。另外，设置一定的页是否应该被加载.
 
 @param htmlString 加载的请求链接
 @param loadedBlock 加载完成后回调
 @param failureBlock 加载失败回调
 @param loadStartedBlock 加载开始时回调
 @param shouldLoadBlock 回调块确定一个特定的页面是否应该被加载
 @return UIWebView
 */
+(UIWebView *)loadHTMLString:(NSString *)htmlString
                      loaded:(CSUIWebViewloadRequestCompleted)loadedBlock
                      failed:(CSUIWebViewloadRequestFailed)failureBlock
                 loadStarted:(CSUIWebViewloadRequestStarted)loadStartedBlock
                  shouldLoad:(CSUIWebViewloadRequestShould)shouldLoadBlock;

///MARK:==========================================
///MARK:代理转回调相关
///MARK:==========================================


///MARK:==========================================
///MARK:画布相关(Canvas)
///MARK:==========================================

/// 创建一个指定大小的画布
- (void)createCanvas:(NSString *)canvasId
               width:(NSInteger)width
              height:(NSInteger)height;
/// 在指定位置创建一个指定大小的画布
- (void)createCanvas:(NSString *)canvasId
               width:(NSInteger)width
              height:(NSInteger)height
                   x:(NSInteger)x
                   y:(NSInteger)y;
/// 绘制矩形填充 context.fillRect(x,y,width,height)
- (void)fillRectOnCanvas:(NSString *)canvasId
                       x:(NSInteger)x
                       y:(NSInteger)y
                   width:(NSInteger)width
                  height:(NSInteger)height
                 uicolor:(UIColor *)color;
/// 绘制矩形边框 context.strokeRect(x,y,width,height)
- (void)strokeRectOnCanvas:(NSString *)canvasId
                         x:(NSInteger)x
                         y:(NSInteger)y
                     width:(NSInteger)width
                    height:(NSInteger)height
                   uicolor:(UIColor *)color
                 lineWidth:(NSInteger)lineWidth;
/// 清除矩形区域 context.clearRect(x,y,width,height)
- (void)clearRectOnCanvas:(NSString *)canvasId
                        x:(NSInteger)x
                        y:(NSInteger)y
                    width:(NSInteger)width
                   height:(NSInteger) height;
/// 绘制圆弧填充 context.arc(x, y, radius, starAngle,endAngle, anticlockwise)
- (void)arcOnCanvas:(NSString *)canvasId
            centerX:(NSInteger)x
            centerY:(NSInteger)y
             radius:(NSInteger)r
         startAngle:(float)startAngle
           endAngle:(float)endAngle
      anticlockwise:(BOOL)anticlockwise
            uicolor:(UIColor *)color;
/// 绘制一条线段 context.moveTo(x,y) context.lineTo(x,y)
- (void)lineOnCanvas:(NSString *)canvasId
                  x1:(NSInteger)x1
                  y1:(NSInteger)y1
                  x2:(NSInteger)x2
                  y2:(NSInteger)y2
             uicolor:(UIColor *)color
           lineWidth:(NSInteger)lineWidth;
/// 绘制一条折线
- (void)linesOnCanvas:(NSString *)canvasId
               points:(NSArray *)points
             unicolor:(UIColor *)color
            lineWidth:(NSInteger)lineWidth;
/// 绘制贝塞尔曲线 context.bezierCurveTo(cp1x,cp1y,cp2x,cp2y,x,y)
- (void)bezierCurveOnCanvas:(NSString *)canvasId
                         x1:(NSInteger)x1
                         y1:(NSInteger)y1
                       cp1x:(NSInteger)cp1x
                       cp1y:(NSInteger)cp1y
                       cp2x:(NSInteger)cp2x
                       cp2y:(NSInteger)cp2y
                         x2:(NSInteger)x2
                         y2:(NSInteger)y2
                   unicolor:(UIColor *)color
                  lineWidth:(NSInteger)lineWidth;
/// 绘制二次样条曲线 context.quadraticCurveTo(qcpx,qcpy,qx,qy)
// coming soon...
/// 显示图像的一部分 context.drawImage(image,sx,sy,sw,sh,dx,dy,dw,dh)
- (void)drawImage:(NSString *)src
         onCanvas:(NSString *)canvasId
               sx:(NSInteger)sx
               sy:(NSInteger)sy
               sw:(NSInteger)sw
               sh:(NSInteger)sh
               dx:(NSInteger)dx
               dy:(NSInteger)dy
               dw:(NSInteger)dw
               dh:(NSInteger)dh;


///MARK:==========================================
///MARK:画布相关(Canvas)
///MARK:==========================================


///MARK:==========================================
///MARK:加载相关load
///MARK:==========================================

/**
 *  @brief  读取一个网页地址
 *
 *  @param URLString 网页地址
 */
- (void)loadURL:(NSString*)URLString;
/**
 *  @brief  读取bundle中的webview
 *
 *  @param htmlName 文件名称 xxx.html
 */
- (void)loadLocalHtml:(NSString*)htmlName;
/**
 *
 *  读取bundle中的webview
 *
 *  @param htmlName htmlName 文件名称 xxx.html
 *  @param inBundle bundle
 */
- (void)loadLocalHtml:(NSString*)htmlName inBundle:(NSBundle*)inBundle;

/**
 *  @brief  清空cookie
 */
- (void)clearCookies;

/**
 *  @brief  获取网页meta信息
 *
 *  @return meta信息
 */
-(NSArray *)getMetaData;


/**
 *  @brief  是否显示阴影
 *
 *  @param hidden 是否显示阴影
 */
- (void)shadowViewHidden:(BOOL)hidden;

/**
 *  @brief  是否显示水平滑动指示器
 *
 *  @param hidden 是否显示水平滑动指示器
 */
- (void)showsHorizontalScrollIndicator:(BOOL)hidden;
/**
 *  @brief  是否显示垂直滑动指示器
 *
 *  @param hidden 是否显示垂直滑动指示器
 */
- (void)showsVerticalScrollIndicator:(BOOL)hidden;

/**
 *  @brief  网页透明
 */
-(void)makeTransparent;
/**
 *  @brief  网页透明移除+阴影
 */
-(void)makeTransparentAndRemoveShadow;


/**
 *  使用滑动手势
 */
- (void)useSwipeGesture;

///MARK:==========================================
///MARK:加载相关load
///MARK:==========================================


///MARK:==========================================
///MARK:JavaScript相关
///MARK:==========================================

#pragma mark -
#pragma mark 获取网页中的数据
/// 获取某个标签的结点个数
- (int)nodeCountOfTag:(NSString *)tag;
/// 获取当前页面URL
- (NSString *)getCurrentURL;
/// 获取标题
- (NSString *)getTitle;
/// 获取图片
- (NSArray *)getImgs;
/// 获取当前页面所有链接
- (NSArray *)getOnClicks;
#pragma mark -
#pragma mark 改变网页样式和行为
/// 改变背景颜色
- (void)setBackgroundColor:(UIColor *)color;
/// 为所有图片添加点击事件(网页中有些图片添加无效)
- (void)addClickEventOnImg;
/// 改变所有图像的宽度
- (void)setImgWidth:(int)size;
/// 改变所有图像的高度
- (void)setImgHeight:(int)size;
/// 改变指定标签的字体颜色
- (void)setFontColor:(UIColor *) color withTag:(NSString *)tagName;
/// 改变指定标签的字体大小
- (void)setFontSize:(int) size withTag:(NSString *)tagName;

///MARK:==========================================
///MARK:JavaScript相关
///MARK:==========================================


///MARK:==========================================
///MARK:JavaScriptCore相关
///MARK:==========================================

@property (nonatomic, readonly) JSContext* _javaScriptContext;

///MARK:==========================================
///MARK:JavaScriptCore相关
///MARK:==========================================


@end



