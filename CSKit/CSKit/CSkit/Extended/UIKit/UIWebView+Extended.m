//
//  UIWebView+Extended.m
//  CSCategory
//
//  Created by 刘聪 on 2017/7/16.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIWebView+Extended.h"
#import "UIColor+Extended.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>

#if __has_include(<CSkit/CSkit.h>)
#import <CSkit/CSMacrosHeader.h>
#import <CSkit/NSString+Extended.h>
#else
#import "CSMacrosHeader.h"
#import "NSString+Extended.h"
#endif

static void (^__loadedBlock)(UIWebView *webView);
static void (^__failureBlock)(UIWebView *webView, NSError *error);
static void (^__loadStartedBlock)(UIWebView *webView);
static BOOL (^__shouldLoadBlock)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType);

static uint __loadedWebItems;

@interface UIWebView ()<UIGestureRecognizerDelegate>

@end


///MARK:==========================================
///MARK:JavaScriptCore相关
///MARK:==========================================

static const char kJavaScriptContext[] = "_javaScriptContext";

static NSHashTable* g_webViews = nil;

@interface UIWebView (_JavaScriptCore_private)
- (void)_didCreateJavaScriptContext:(JSContext *)_javaScriptContext;
@end

@protocol CSWebFrame <NSObject>
- (id) parentFrame;
@end

@implementation NSObject (_JavaScriptContext)

- (void)webView:(id) unused didCreateJavaScriptContext:(JSContext*)ctx forFrame:(id<CSWebFrame>) frame
{
    NSParameterAssert( [frame respondsToSelector: @selector( parentFrame )] );
    
    // only interested in root-level frames
    if ( [frame respondsToSelector: @selector( parentFrame) ] && [frame parentFrame] != nil )
        return;
    
    void (^notifyDidCreateJavaScriptContext)() = ^{
        
        for ( UIWebView* webView in g_webViews )
        {
            NSString* cookie = [NSString stringWithFormat: @"_jscWebView_%lud", (unsigned long)webView.hash ];
            
            [webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"var %@ = '%@'", cookie, cookie ] ];
            
            if ( [ctx[cookie].toString isEqualToString: cookie] )
            {
                [webView _didCreateJavaScriptContext:ctx];
                return;
            }
        }
    };
    
    if ( [NSThread isMainThread] )
    {
        notifyDidCreateJavaScriptContext();
    }
    else
    {
        dispatch_async( dispatch_get_main_queue(), notifyDidCreateJavaScriptContext );
    }
}

@end

///MARK:==========================================
///MARK:JavaScriptCore相关
///MARK:==========================================


@implementation UIWebView (Extended)


///MARK:==========================================
///MARK:JavaScriptCore相关
///MARK:==========================================

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        g_webViews = [NSHashTable weakObjectsHashTable];
    });
    
    NSAssert( [NSThread isMainThread], @"uh oh - why aren't we on the main thread?");
    
    id webView = [super allocWithZone: zone];
    
    [g_webViews addObject: webView];
    
    return webView;
}

- (void)ts_didCreateJavaScriptContext:(JSContext *)ts_javaScriptContext
{
    [self willChangeValueForKey: @"_javaScriptContext"];
    
    objc_setAssociatedObject( self, kJavaScriptContext, ts_javaScriptContext, OBJC_ASSOCIATION_RETAIN);
    
    [self didChangeValueForKey: @"_javaScriptContext"];
    
    if ( [self.delegate respondsToSelector: @selector(webView:didCreateJavaScriptContext:)] )
    {
        id<CSJSWebViewDelegate> delegate = ( id<CSJSWebViewDelegate>)self.delegate;
        [delegate webView: self didCreateJavaScriptContext: ts_javaScriptContext];
    }
}

- (JSContext*)_javaScriptContext
{
    JSContext* javaScriptContext = objc_getAssociatedObject( self, kJavaScriptContext );
    
    return javaScriptContext;
}

///MARK:==========================================
///MARK:JavaScriptCore相关
///MARK:==========================================



///MARK:==========================================
///MARK:代理转回调相关
///MARK:==========================================

+ (UIWebView *)loadRequest: (NSURLRequest *) request
                    loaded: (CSUIWebViewloadRequestCompleted) loadedBlock
                    failed: (CSUIWebViewloadRequestFailed) failureBlock{
    
    return [self loadRequest:request loaded:loadedBlock failed:failureBlock loadStarted:nil shouldLoad:nil];
}

+(UIWebView *)loadHTMLString:(NSString *)htmlString
                      loaded:(CSUIWebViewloadRequestCompleted)loadedBlock
                      failed:(CSUIWebViewloadRequestFailed)failureBlock{
    
    return [self loadHTMLString:htmlString loaded:loadedBlock failed:failureBlock loadStarted:nil shouldLoad:nil];
}

+(UIWebView *)loadHTMLString:(NSString *)htmlString
                      loaded:(CSUIWebViewloadRequestCompleted)loadedBlock
                      failed:(CSUIWebViewloadRequestFailed)failureBlock
                 loadStarted:(CSUIWebViewloadRequestStarted)loadStartedBlock
                  shouldLoad:(CSUIWebViewloadRequestShould)shouldLoadBlock{
    __loadedWebItems = 0;
    __loadedBlock = loadedBlock;
    __failureBlock = failureBlock;
    __loadStartedBlock = loadStartedBlock;
    __shouldLoadBlock = shouldLoadBlock;
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = (id)[self class];
    [webView loadHTMLString:htmlString baseURL:nil];
    
    return webView;
}

+ (UIWebView *)loadRequest: (NSURLRequest *) request
                    loaded: (CSUIWebViewloadRequestCompleted) loadedBlock
                    failed: (CSUIWebViewloadRequestFailed) failureBlock
               loadStarted: (CSUIWebViewloadRequestStarted) loadStartedBlock
                shouldLoad: (CSUIWebViewloadRequestShould) shouldLoadBlock{
    __loadedWebItems    = 0;
    
    __loadedBlock       = loadedBlock;
    __failureBlock      = failureBlock;
    __loadStartedBlock  = loadStartedBlock;
    __shouldLoadBlock   = shouldLoadBlock;
    
    UIWebView *webView  = [[UIWebView alloc] init];
    webView.delegate    = (id) [self class];
    
    [webView loadRequest: request];
    
    return webView;
}

#pragma mark - Private Static delegate
+(void)webViewDidFinishLoad:(UIWebView *)webView{
    __loadedWebItems--;
    
    if(__loadedBlock && (!TRUE_END_REPORT || __loadedWebItems == 0)){
        __loadedWebItems = 0;
        __loadedBlock(webView);
    }
}

+(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    __loadedWebItems--;
    
    if(__failureBlock)
        __failureBlock(webView, error);
}

+(void)webViewDidStartLoad:(UIWebView *)webView{
    __loadedWebItems++;
    
    if(__loadStartedBlock && (!TRUE_END_REPORT || __loadedWebItems > 0))
        __loadStartedBlock(webView);
}

+(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if(__shouldLoadBlock)
        return __shouldLoadBlock(webView, request, navigationType);
    
    return YES;
}

///MARK:==========================================
///MARK:代理转回调相关
///MARK:==========================================


///MARK:==========================================
///MARK:画布相关(Canvas)
///MARK:==========================================

/// 创建一个指定大小的透明画布
- (void)createCanvas:(NSString *)canvasId width:(NSInteger)width height:(NSInteger)height
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.createElement('canvas');"
                          "canvas.id = %@; canvas.width = %ld; canvas.height = %ld;"
                          "document.body.appendChild(canvas);"
                          "var g = canvas.getContext('2d');"
                          "g.strokeRect(%ld,%ld,%ld,%ld);",
                          canvasId, (long)width, (long)height, 0L ,0L ,(long)width,(long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 在指定位置创建一个指定大小的透明画布
- (void)createCanvas:(NSString *)canvasId width:(NSInteger)width height:(NSInteger)height x:(NSInteger)x y:(NSInteger)y
{
    //[self createCanvas:canvasId width:width height:height];
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.createElement('canvas');"
                          "canvas.id = %@; canvas.width = %ld; canvas.height = %ld;"
                          "canvas.style.position = 'absolute';"
                          "canvas.style.top = '%ld';"
                          "canvas.style.left = '%ld';"
                          "document.body.appendChild(canvas);"
                          "var g = canvas.getContext('2d');"
                          "g.strokeRect(%ld,%ld,%ld,%ld);",
                          canvasId, (long)width, (long)height, (long)y, (long)x, 0L ,0L ,(long)width,(long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 绘制矩形填充 context.fillRect(x,y,width,height)
- (void)fillRectOnCanvas:(NSString *)canvasId x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger) height uicolor:(UIColor *)color
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.fillStyle = '%@';"
                          "context.fillRect(%ld,%ld,%ld,%ld);"
                          ,canvasId, [color canvasColorString], (long)x, (long)y, (long)width, (long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 绘制矩形边框 strokeRect(x,y,width,height)
- (void)strokeRectOnCanvas:(NSString *)canvasId x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger) height uicolor:(UIColor *)color lineWidth:(NSInteger)lineWidth
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.strokeStyle = '%@';"
                          "context.lineWidth = '%ld';"
                          "context.strokeRect(%ld,%ld,%ld,%ld);"
                          ,canvasId, [color canvasColorString], (long)lineWidth, (long)x, (long)y, (long)width, (long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 清除矩形区域 context.clearRect(x,y,width,height)
- (void)clearRectOnCanvas:(NSString *)canvasId x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger) height
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.clearRect(%ld,%ld,%ld,%ld);"
                          ,canvasId, (long)x, (long)y, (long)width, (long)height];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 绘制圆弧填充 context.arc(x, y, radius, starAngle,endAngle, anticlockwise)
- (void)arcOnCanvas:(NSString *)canvasId centerX:(NSInteger)x centerY:(NSInteger)y radius:(NSInteger)r startAngle:(float)startAngle endAngle:(float)endAngle anticlockwise:(BOOL)anticlockwise uicolor:(UIColor *)color
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.beginPath();"
                          "context.arc(%ld,%ld,%ld,%f,%f,%@);"
                          "context.closePath();"
                          "context.fillStyle = '%@';"
                          "context.fill();",
                          canvasId, (long)x, (long)y, (long)r, startAngle, endAngle, anticlockwise ? @"true" : @"false", [color canvasColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 绘制一条线段 context.moveTo(x,y) context.lineTo(x,y)
- (void)lineOnCanvas:(NSString *)canvasId x1:(NSInteger)x1 y1:(NSInteger)y1 x2:(NSInteger)x2 y2:(NSInteger)y2 uicolor:(UIColor *)color lineWidth:(NSInteger)lineWidth
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.beginPath();"
                          "context.moveTo(%ld,%ld);"
                          "context.lineTo(%ld,%ld);"
                          "context.closePath();"
                          "context.strokeStyle = '%@';"
                          "context.lineWidth = %ld;"
                          "context.stroke();",
                          canvasId, (long)x1, (long)y1, (long)x2, (long)y2, [color canvasColorString], (long)lineWidth];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 绘制一条折线
- (void)linesOnCanvas:(NSString *)canvasId points:(NSArray *)points unicolor:(UIColor *)color lineWidth:(NSInteger)lineWidth
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.beginPath();",
                          canvasId];
    for (int i = 0; i < [points count] / 2; i++) {
        jsString = [jsString stringByAppendingFormat:@"context.lineTo(%@,%@);",
                    points[i * 2], points[i * 2 + 1]];
    }
    jsString = [jsString stringByAppendingFormat:@""
                "context.strokeStyle = '%@';"
                "context.lineWidth = %ld;"
                "context.stroke();",
                [color canvasColorString], (long)lineWidth];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
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
                  lineWidth:(NSInteger)lineWidth
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.beginPath();"
                          "context.moveTo(%ld,%ld);"
                          "context.bezierCurveTo(%ld,%ld,%ld,%ld,%ld,%ld);"
                          "context.strokeStyle = '%@';"
                          "context.lineWidth = %ld;"
                          "context.stroke();",
                          canvasId, (long)x1, (long)y1, (long)cp1x, (long)cp1y, (long)cp2x, (long)cp2y, (long)x2, (long)y2, [color canvasColorString], (long)lineWidth];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
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
               dh:(NSInteger)dh
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var image = new Image();"
                          "image.src = '%@';"
                          "var canvas = document.getElementById('%@');"
                          "var context = canvas.getContext('2d');"
                          "context.drawImage(image,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld)",
                          src, canvasId, (long)sx, (long)sy, (long)sw, (long)sh, (long)dx, (long)dy, (long)dw, (long)dh];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

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
- (void)loadURL:(NSString*)URLString{
    //"Use [NSString stringByAddingPercentEncodingWithAllowedCharacters:] instead, which always uses the recommended UTF-8 encoding, and which encodes for a specific URL component or subcomponent (since each URL component or subcomponent has different rules for what characters are valid).
//    NSString *encodedUrl = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes (NULL, (__bridge CFStringRef) URLString, NULL, NULL,kCFStringEncodingUTF8);
    
    
    
    NSURL *url = [NSURL URLWithString:[URLString stringByURLEncode]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self loadRequest:req];
}
/**
 *  @brief  读取bundle中的webview
 *
 *  @param htmlName webview名称
 */
- (void)loadLocalHtml:(NSString*)htmlName{
    [self loadLocalHtml:htmlName inBundle:[NSBundle mainBundle]];
}
- (void)loadLocalHtml:(NSString*)htmlName inBundle:(NSBundle*)inBundle{
    NSString *filePath = [inBundle pathForResource:htmlName ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadRequest:request];
}
/**
 *  @brief  清空cookie
 */
- (void)clearCookies
{
    NSHTTPCookieStorage *storage = NSHTTPCookieStorage.sharedHTTPCookieStorage;
    
    for (NSHTTPCookie *cookie in storage.cookies)
        [storage deleteCookie:cookie];
    
    [NSUserDefaults.standardUserDefaults synchronize];
}


/**
 *  @brief  获取网页meta信息
 *
 *  @return meta信息
 */
-(NSArray *)getMetaData
{
    NSString *string = [self stringByEvaluatingJavaScriptFromString:@""
                        "var json = '[';                                    "
                        "var a = document.getElementsByTagName('meta');     "
                        "for(var i=0;i<a.length;i++){                       "
                        "   json += '{';                                    "
                        "   var b = a[i].attributes;                        "
                        "   for(var j=0;j<b.length;j++){                    "
                        "       var name = b[j].name;                       "
                        "       var value = b[j].value;                     "
                        "                                                   "
                        "       json += '\"'+name+'\":';                    "
                        "       json += '\"'+value+'\"';                    "
                        "       if(b.length>j+1){                           "
                        "           json += ',';                            "
                        "       }                                           "
                        "   }                                               "
                        "   json += '}';                                    "
                        "   if(a.length>i+1){                               "
                        "       json += ',';                                "
                        "   }                                               "
                        "}                                                  "
                        "json += ']';                                       "];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError*   error = nil;
    id array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if(array==nil) CSNSLog(@"An error occured in meta parser.");
    return array;
}


/**
 *  @brief  是否显示阴影
 *
 *  @param hidden 是否显示阴影
 */
- (void)shadowViewHidden:(BOOL)hidden{
    for (UIView *aView in [self subviews])
    {
        if ([aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)aView setShowsHorizontalScrollIndicator:NO];
            for (UIView *shadowView in aView.subviews)
            {
                if ([shadowView isKindOfClass:[UIImageView class]])
                {
                    shadowView.hidden = hidden;  //上下滚动出边界时的黑色的图片 也就是拖拽后的上下阴影
                }
            }
        }
    }
}
/**
 *  @brief  是否显示水平滑动指示器
 *
 *  @param hidden 是否显示水平滑动指示器
 */
- (void)showsHorizontalScrollIndicator:(BOOL)hidden{
    for (UIView *aView in [self subviews])
    {
        if ([aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)aView setShowsHorizontalScrollIndicator:hidden];
        }
    }
}
/**
 *  @brief  是否显示垂直滑动指示器
 *
 *  @param hidden 是否显示垂直滑动指示器
 */
- (void)showsVerticalScrollIndicator:(BOOL)hidden{
    for (UIView *aView in [self subviews])
    {
        if ([aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)aView setShowsVerticalScrollIndicator:hidden];
        }
    }
}
/**
 *  @brief  网页透明
 */
-(void)makeTransparent
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
}
/**
 *  @brief  网页透明移除阴影
 */
-(void)makeTransparentAndRemoveShadow
{
    [self makeTransparent];
    [self shadowViewHidden:YES];
}



- (void)useSwipeGesture {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeRight setNumberOfTouchesRequired:2];
    [swipeRight setDelegate:self];
    [self addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeLeft setNumberOfTouchesRequired:2];
    [swipeLeft setDelegate:self];
    [self addGestureRecognizer:swipeLeft];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan setMaximumNumberOfTouches:2];
    [pan setMinimumNumberOfTouches:2];
    [self addGestureRecognizer:pan];
    
    [pan requireGestureRecognizerToFail:swipeLeft];
    [pan requireGestureRecognizerToFail:swipeRight];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer {
    if([recognizer numberOfTouches] == 2 && [self canGoBack]) [self goBack];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer {
    if([recognizer numberOfTouches] == 2 && [self canGoForward]) [self goForward];
}

///MARK:==========================================
///MARK:加载相关load
///MARK:==========================================



///MARK:==========================================
///MARK:JavaScript相关
///MARK:==========================================

#pragma mark -
#pragma mark 获取网页中的数据
/// 获取某个标签的结点个数
- (int)nodeCountOfTag:(NSString *)tag
{
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('%@').length", tag];
    int len = [[self stringByEvaluatingJavaScriptFromString:jsString] intValue];
    return len;
}
/// 获取当前页面URL
- (NSString *)getCurrentURL
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.location.href"];
}
/// 获取标题
- (NSString *)getTitle
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}
/// 获取所有图片链接
- (NSArray *)getImgs
{
    NSMutableArray *arrImgURL = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].src", i];
        [arrImgURL addObject:[self stringByEvaluatingJavaScriptFromString:jsString]];
    }
    return arrImgURL;
}
/// 获取当前页面所有点击链接
- (NSArray *)getOnClicks
{
    NSMutableArray *arrOnClicks = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self nodeCountOfTag:@"a"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('a')[%d].getAttribute('onclick')", i];
        NSString *clickString = [self stringByEvaluatingJavaScriptFromString:jsString];
        CSNSLog(@"%@", clickString);
        [arrOnClicks addObject:clickString];
    }
    return arrOnClicks;
}
#pragma mark -
#pragma mark 改变网页样式和行为
/// 改变背景颜色
- (void)setBackgroundColor:(UIColor *)color
{
    NSString * jsString = [NSString stringWithFormat:@"document.body.style.backgroundColor = '%@'",[color webColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 为所有图片添加点击事件(网页中有些图片添加无效,需要协议方法配合截取)
- (void)addClickEventOnImg
{
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        //利用重定向获取img.src，为区分，给url添加'img:'前缀
        NSString *jsString = [NSString stringWithFormat:
                              @"document.getElementsByTagName('img')[%d].onclick = \
                              function() { document.location.href = 'img' + this.src; }",i];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}
/// 改变所有图像的宽度
- (void)setImgWidth:(int)size
{
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].width = '%d'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
        jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.width = '%dpx'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}
/// 改变所有图像的高度
- (void)setImgHeight:(int)size
{
    for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
        NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].height = '%d'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
        jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.height = '%dpx'", i, size];
        [self stringByEvaluatingJavaScriptFromString:jsString];
    }
}
/// 改变指定标签的字体颜色
- (void)setFontColor:(UIColor *)color withTag:(NSString *)tagName
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.color = '%@';}", tagName, [color webColorString]];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}
/// 改变指定标签的字体大小
- (void)setFontSize:(int)size withTag:(NSString *)tagName
{
    NSString *jsString = [NSString stringWithFormat:
                          @"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.fontSize = '%dpx';}", tagName, size];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

///MARK:==========================================
///MARK:JavaScript相关
///MARK:==========================================



@end


