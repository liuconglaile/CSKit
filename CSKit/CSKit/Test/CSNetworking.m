//
//  CSNetworking.m
//  NewWorkersAbout
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 CS-Moming. All rights reserved.
//

#import "CSNetworking.h"
#import <AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#import <AFNetworkActivityIndicatorManager.h>

// 项目打包上线都不会打印日志，因此可放心。
#ifdef DEBUG
#define CSAppLog(FORMAT, ...) fprintf(stderr,"\n\n\n🍎🍎🍎方法:%s \n🍊🍊🍊行号:%d \n🍌🍌🍌内容:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else // 开发模式
#define CSAppLog(FORMAT, ...) nil
#endif


@interface NSString (md5)

+ (NSString *)csNetworking_md5:(NSString *)string;

@end

@implementation NSString (md5)

+ (NSString *)csNetworking_md5:(NSString *)string {
    if (string == nil || [string length] == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    return [ms copy];
}

@end


static NSString       *sg_privateNetworkBaseUrl = nil;
static BOOL            sg_isEnableInterfaceDebug = NO;
static BOOL            sg_shouldAutoEncode = NO;
static NSDictionary   *sg_httpHeaders = nil;
static CSResponseType  sg_responseType = kCSResponseTypeJSON;
static CSRequestType   sg_requestType  = kCSRequestTypePlainText;
static NSMutableArray *sg_requestTasks;
static BOOL            sg_cacheGet = YES;
static BOOL            sg_cachePost = NO;
static BOOL            sg_shouldCallbackOnCancelRequest = YES;



@implementation CSNetworking

+ (void)cacheGetRequest:(BOOL)isCacheGet shoulCachePost:(BOOL)shouldCachePost {
    sg_cacheGet = isCacheGet;
    sg_cachePost = shouldCachePost;
}

+ (void)updateBaseUrl:(NSString *)baseUrl {
    sg_privateNetworkBaseUrl = baseUrl;
}

+ (NSString *)baseUrl {
    return sg_privateNetworkBaseUrl;
}

+ (void)enableInterfaceDebug:(BOOL)isDebug {
    sg_isEnableInterfaceDebug = isDebug;
}

+ (BOOL)isDebug {
    return sg_isEnableInterfaceDebug;
}

static inline NSString *cachePath() {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CSNetworkingCaches"];
}

+ (void)clearCaches {
    NSString *directoryPath = cachePath();
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
        
        if (error) {
            NSLog(@"CSNetworking 清除缓存错误: %@", error);
        } else {
            NSLog(@"CSNetworking 清除缓存成功!");
        }
    }
}

+ (unsigned long long)totalCacheSize {
    NSString *directoryPath = cachePath();
    BOOL isDir = NO;
    unsigned long long total = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                          error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    
    return total;
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sg_requestTasks == nil) {
            sg_requestTasks = [[NSMutableArray alloc] init];
        }
    });
    
    return sg_requestTasks;
}

/** 取消所有请求 */
+ (void)cancelAllRequest {
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(CSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[CSURLSessionTask class]]) {
                [task cancel];
            }
        }];
        
        [[self allTasks] removeAllObjects];
    };
}

/**
 取消某个请求.如果是要取消某个请求,最好是引用接口所返回来的CSURLSessionTask对象,
 然后调用对象的cancel方法.如果不想引用对象,这里额外提供了一种方法来实现取消某个请求
 
 @param url URL,可以是绝对URL,也可以是path（也就是不包括baseurl）
 */
+ (void)cancelRequestWithURL:(NSString *)url {
    if (url == nil) {
        return;
    }
    
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(CSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[CSURLSessionTask class]]
                && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                return;
            }
        }];
    };
}

+ (void)configRequestType:(CSRequestType)requestType
             responseType:(CSResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
  callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest {
    sg_requestType = requestType;
    sg_responseType = responseType;
    sg_shouldAutoEncode = shouldAutoEncode;
    sg_shouldCallbackOnCancelRequest = shouldCallbackOnCancelRequest;
}

+ (BOOL)shouldEncode {
    return sg_shouldAutoEncode;
}

+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders {
    sg_httpHeaders = httpHeaders;
}

///MARK: GET请求接口 不带参数
+ (CSURLSessionTask *)getWithUrl:(NSString *)url refreshCache:(BOOL)refreshCache success:(CSResponseSuccess)success fail:(CSResponseFail)fail {
    /**
     GET请求接口,若不指定baseurl,可传完整的url
     
     @param url 接口路径,如/path/getArticleList
     @param refreshCache 是否刷新缓存.由于请求成功也可能没有数据,对于业务失败,只能通过人为手动判断
     @param success 接口成功请求到数据的回调
     @param fail 接口请求数据失败的回调
     @return 返回的对象中有可取消请求的API
     */
    return [self getWithUrl:url refreshCache:refreshCache params:nil success:success fail:fail];
}

///MARK: GET请求接口
+ (CSURLSessionTask *)getWithUrl:(NSString *)url refreshCache:(BOOL)refreshCache params:(NSDictionary *)params success:(CSResponseSuccess)success fail:(CSResponseFail)fail {
    /**
     GET请求接口
     
     @param url 接口路径,如/path/getArticleList
     @param refreshCache 是否缓存
     @param params 接口中所需要的拼接参数,如@{"categoryid" : @(12)}
     @param success 接口成功请求到数据的回调
     @param fail 接口请求数据失败的回调
     @return 返回的对象中有可取消请求的API
     */
    return [self getWithUrl:url refreshCache:refreshCache params:params progress:nil success:success fail:fail];
}
///MARK: 多一个带进度回调的 POST 请求
+ (CSURLSessionTask *)getWithUrl:(NSString *)url refreshCache:(BOOL)refreshCache params:(NSDictionary *)params progress:(CSGetProgress)progress success:(CSResponseSuccess)success fail:(CSResponseFail)fail {
    return [self _requestWithUrl:url refreshCache:refreshCache httpMedth:1 params:params progress:progress success:success fail:fail];
}

///MARK: POST请求接口,若不指定baseurl,可传完整的url
+ (CSURLSessionTask *)postWithUrl:(NSString *)url refreshCache:(BOOL)refreshCache params:(NSDictionary *)params success:(CSResponseSuccess)success fail:(CSResponseFail)fail {
    /**
     POST请求接口,若不指定baseurl,可传完整的url
     
     @param url 接口路径,如/path/getArticleList
     @param refreshCache 是否缓存
     @param params 接口中所需的参数,如@{"categoryid" : @(12)}
     @param success 接口成功请求到数据的回调
     @param fail 接口请求数据失败的回调
     @return 返回的对象中有可取消请求的API
     */
    return [self postWithUrl:url refreshCache:refreshCache params:params progress:nil success:success fail:fail];
}

+ (CSURLSessionTask *)postWithUrl:(NSString *)url refreshCache:(BOOL)refreshCache params:(NSDictionary *)params progress:(CSPostProgress)progress success:(CSResponseSuccess)success fail:(CSResponseFail)fail {
    return [self _requestWithUrl:url refreshCache:refreshCache httpMedth:2 params:params progress:progress success:success fail:fail];
}

+ (CSURLSessionTask *)_requestWithUrl:(NSString *)url
                         refreshCache:(BOOL)refreshCache
                            httpMedth:(NSUInteger)httpMethod
                               params:(NSDictionary *)params
                             progress:(CSDownloadProgress)progress
                              success:(CSResponseSuccess)success
                                 fail:(CSResponseFail)fail {
    
    AFHTTPSessionManager *manager = [self manager];
    NSString *absolute = [self absoluteUrlWithPath:url];
    
    
    
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            
            CSAppLog(@"URLString无效,无法生成URL.可能是URL中有中文,请尝试Encode URL");
            return nil;
        }
    } else {
        NSURL *absouluteURL = [NSURL URLWithString:absolute];
        
        if (absouluteURL == nil) {
            CSAppLog(@"URLString无效,无法生成URL.可能是URL中有中文,请尝试Encode URL");
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    CSURLSessionTask *session = nil;
    
    if (httpMethod == 1) {
        if (sg_cacheGet && !refreshCache) {// 获取缓存
            id response = [CSNetworking cahceResponseWithURL:absolute parameters:params];
            if (response) {
                if (success) {
                    [self successResponse:response callback:success];
                    
                    if ([self isDebug]) {
                        [self logWithSuccessResponse:response url:absolute params:params];
                    }
                }
                
                return nil;
            }
        }
        
        session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self successResponse:responseObject callback:success];
            
            if (sg_cacheGet) {
                [self cacheResponseObject:responseObject request:task.currentRequest parameters:params];
            }
            
            [[self allTasks] removeObject:task];
            
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:absolute
                                      params:params];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug]) {
                [self logWithFailError:error url:absolute params:params];
            }
        }];
    } else if (httpMethod == 2) {
        if (sg_cachePost && !refreshCache) {// 获取缓存
            id response = [CSNetworking cahceResponseWithURL:absolute
                                                  parameters:params];
            
            if (response) {
                if (success) {
                    [self successResponse:response callback:success];
                    
                    if ([self isDebug]) {
                        [self logWithSuccessResponse:response
                                                 url:absolute
                                              params:params];
                    }
                }
                
                return nil;
            }
        }
        
        session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self successResponse:responseObject callback:success];
            
            if (sg_cachePost) {
                [self cacheResponseObject:responseObject request:task.currentRequest  parameters:params];
            }
            
            [[self allTasks] removeObject:task];
            
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:absolute
                                      params:params];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[self allTasks] removeObject:task];
            
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug]) {
                [self logWithFailError:error url:absolute params:params];
            }
        }];
    }
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

///MARK: 上传文件操作
+ (CSURLSessionTask *)uploadFileWithUrl:(NSString *)url
                          uploadingFile:(NSString *)uploadingFile
                               progress:(CSUploadProgress)progress
                                success:(CSResponseSuccess)success
                                   fail:(CSResponseFail)fail {
    /**
     上传文件操作
     
     @param url 上传路径
     @param uploadingFile 待上传文件的路径
     @param progress 上传进度
     @param success 上传成功回调
     @param fail 上传失败回调
     @return 请求体
     */
    
    if ([NSURL URLWithString:uploadingFile] == nil) {
        CSAppLog(@"uploadingFile无效,无法生成URL.请检查待上传文件是否存在");
        return nil;
    }
    
    NSURL *uploadURL = nil;
    if ([self baseUrl] == nil) {
        uploadURL = [NSURL URLWithString:url];
    } else {
        uploadURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]];
    }
    
    if (uploadURL == nil) {
        CSAppLog(@"URLString无效,无法生成URL.可能是URL中有中文或特殊字符,请尝试Encode URL");
        return nil;
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    AFHTTPSessionManager *manager = [self manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:uploadURL];
    CSURLSessionTask *session = nil;
    
    [manager uploadTaskWithRequest:request fromFile:[NSURL URLWithString:uploadingFile] progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [[self allTasks] removeObject:session];
        
        [self successResponse:responseObject callback:success];
        
        if (error) {
            [self handleCallbackWithError:error fail:fail];
            
            if ([self isDebug]) {
                [self logWithFailError:error url:response.URL.absoluteString params:nil];
            }
        } else {
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:response.URL.absoluteString
                                      params:nil];
            }
        }
    }];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}


///MARK: 上传多张图片接口
+ (CSURLSessionTask *)uploadWithImages:(NSArray *)images
                                   url:(NSString *)url
                              filename:(NSString *)filename
                                  name:(NSString *)name
                              mimeType:(NSString *)mimeType
                            parameters:(NSDictionary *)parameters
                              progress:(CSUploadProgress)progress
                               success:(CSResponseSuccess)success
                                  fail:(CSResponseFail)fail {
    
    /**
     上传多张图片
     
     @param images 图片对象
     @param url 上传图片的接口路径,如/path/images/
     @param filename 给图片起一个名字,默认为当前日期时间,格式为"yyyyMMddHHmmss",后缀为'jpg'
     @param name 与指定的图片相关联的名称,这是由后端写接口的人指定的,如imagefiles
     @param mimeType 默认为image/jpeg
     @param parameters 参数
     @param progress 上传进度
     @param success 上传成功回调
     @param fail 上传失败回调
     @return 请求体
     */
    
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            CSAppLog(@"URLString无效,无法生成URL.可能是URL中有中文,请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            CSAppLog(@"URLString无效,无法生成URL.可能是URL中有中文,请尝试Encode URL");
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    NSString *absolute = [self absoluteUrlWithPath:url];
    
    AFHTTPSessionManager *manager = [self manager];
    
    CSURLSessionTask *session = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        
        // 上传 多张图片
        for(NSInteger i = 0; i < images.count; i++)
        {
            NSData *imageData = UIImageJPEGRepresentation(images[i], 1);
            
            NSString *imageFileName = filename;
            if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyyMMddHHmmss";
                NSString *str = [formatter stringFromDate:[NSDate date]];
                imageFileName = [NSString stringWithFormat:@"%@_%ld.jpg", str,(long)i];
            }
            
            //CSAppLog(@"🐍🐍🐍🐍🐍🐍我是数据流:------<%@>",imageData);
            
            // 上传图片,以文件流的格式
            [formData appendPartWithFileData:imageData name:[name stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)i]] fileName:imageFileName mimeType:mimeType];
            
            //CSAppLog(@"我是发布的图片: %@\n %@\n %@\n",imageFileName,mimeType,[name stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)i]]);
        }
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allTasks] removeObject:task];
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug]) {
            [self logWithSuccessResponse:responseObject
                                     url:absolute
                                  params:parameters];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allTasks] removeObject:task];
        
        [self handleCallbackWithError:error fail:fail];
        
        if ([self isDebug]) {
            [self logWithFailError:error url:absolute params:nil];
        }
    }];
    
    [session resume];
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}


///MARK: 图片上传接口
+ (CSURLSessionTask *)uploadWithImage:(UIImage *)image
                                  url:(NSString *)url
                             filename:(NSString *)filename
                                 name:(NSString *)name
                             mimeType:(NSString *)mimeType
                           parameters:(NSDictionary *)parameters
                             progress:(CSUploadProgress)progress
                              success:(CSResponseSuccess)success
                                 fail:(CSResponseFail)fail {
    
    /**
     图片上传接口,若不指定baseurl,可传完整的url
     
     @param image 图片对象
     @param url 上传图片的接口路径,如/path/images/
     @param filename 给图片起一个名字,默认为当前日期时间,格式为"yyyyMMddHHmmss",后缀为'jpg'
     @param name 与指定的图片相关联的名称,这是由后端写接口的人指定的,如imagefiles
     @param mimeType 默认为image/jpeg
     @param parameters 参数
     @param progress 上传进度
     @param success 上传成功回调
     @param fail 上传失败回调
     @return 请求体
     */
    
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            CSAppLog(@"URLString无效,无法生成URL.可能是URL中有中文,请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            CSAppLog(@"URLString无效,无法生成URL.可能是URL中有中文,请尝试Encode URL");
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    NSString *absolute = [self absoluteUrlWithPath:url];
    
    AFHTTPSessionManager *manager = [self manager];
    CSURLSessionTask *session = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        
        // 上传图片,以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allTasks] removeObject:task];
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug]) {
            [self logWithSuccessResponse:responseObject
                                     url:absolute
                                  params:parameters];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allTasks] removeObject:task];
        
        [self handleCallbackWithError:error fail:fail];
        
        if ([self isDebug]) {
            [self logWithFailError:error url:absolute params:nil];
        }
    }];
    
    [session resume];
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

//MARK: 下载文件
+ (CSURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(CSDownloadProgress)progressBlock
                              success:(CSResponseSuccess)success
                              failure:(CSResponseFail)failure {
    /**
     下载文件
     
     @param url 下载URL
     @param saveToPath 下载到哪个路径下
     @param progressBlock 下载进度
     @param success 下载成功后的回调
     @param failure 下载失败后的回调
     */
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            CSAppLog(@"URLString无效,无法生成URL.可能是URL中有中文,请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            CSAppLog(@"URLString无效,无法生成URL.可能是URL中有中文,请尝试Encode URL");
            return nil;
        }
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self manager];
    
    CSURLSessionTask *session = nil;
    
    session = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL URLWithString:saveToPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allTasks] removeObject:session];
        
        if (error == nil) {
            if (success) {
                success(filePath.absoluteString);
            }
            
            if ([self isDebug]) {
                CSAppLog(@"下载成功的 URL: %@",
                        [self absoluteUrlWithPath:url]);
            }
        } else {
            [self handleCallbackWithError:error fail:failure];
            
            if ([self isDebug]) {
                CSAppLog(@"下载失败 URL: %@, reason : %@",
                        [self absoluteUrlWithPath:url],
                        [error description]);
            }
        }
    }];
    
    [session resume];
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    return session;
}

#pragma mark - Private
+ (AFHTTPSessionManager *)manager {
    // 开启转圈圈
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = nil;;
    if ([self baseUrl] != nil) {
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
    } else {
        manager = [AFHTTPSessionManager manager];
    }
    // 请求类型
    switch (sg_requestType) {
        case kCSRequestTypeJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        }
        case kCSRequestTypePlainText: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    // 响应类型
    switch (sg_responseType) {
        case kCSResponseTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case kCSResponseTypeXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
        case kCSResponseTypeData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    
    for (NSString *key in sg_httpHeaders.allKeys) {
        if (sg_httpHeaders[key] != nil) {
            [manager.requestSerializer setValue:sg_httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    
    ///设置请求超时时间 最大为15秒
    manager.requestSerializer.timeoutInterval = 15;
    ///设置允许同时最大并发数量,过大容易出问题
    manager.operationQueue.maxConcurrentOperationCount = 3;
    return manager;
}

///MARK: 统一打印调试数据
+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params {
    /*
     CSAppLog(@"\n");
     CSAppLog(@"\n请求成功! URL: %@\n 参数:%@\n 返回:%@\n\n",
     [self generateGETAbsoluteURL:url params:params],
     params,
     [self tryToParseData:response]);
     */
}

+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(id)params {
    NSString *format = @" params: ";
    if (params == nil || ![params isKindOfClass:[NSDictionary class]]) {
        format = @"";
        params = @"";
    }
    
    CSAppLog(@"\n");
    if ([error code] == NSURLErrorCancelled) {
        CSAppLog(@"\n请求已手动取消! URL: %@ %@%@\n\n",
                [self generateGETAbsoluteURL:url params:params],
                format,
                params);
    } else {
        CSAppLog(@"\n请求错误! URL: %@ %@%@\n 错误信息:%@\n\n",
                [self generateGETAbsoluteURL:url params:params],
                format,
                params,
                [error localizedDescription]);
    }
}

// 仅对一级字典结构起作用
+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params {
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] || [params count] == 0) {
        return url;
    }
    
    NSString *queries = @"";
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound
            || [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    
    return url.length == 0 ? queries : url;
}


+ (NSString *)encodeUrl:(NSString *)url {
    return [self CS_URLEncode:url];
}

+ (id)tryToParseData:(id)responseData {
    if ([responseData isKindOfClass:[NSData class]]) {
        // 尝试解析成JSON
        if (responseData == nil) {
            return responseData;
        } else {
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
            
            if (error != nil) {
                return responseData;
            } else {
                return response;
            }
        }
    } else {
        return responseData;
    }
}

+ (void)successResponse:(id)responseData callback:(CSResponseSuccess)success {
    if (success) {
        success([self tryToParseData:responseData]);
    }
}

+ (NSString *)CS_URLEncode:(NSString *)url {
    NSString *newString =
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)url,
                                                              NULL,
                                                              CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~'"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString) {
        return newString;
    }
    
    return url;
}

+ (id)cahceResponseWithURL:(NSString *)url parameters:params {
    id cacheData = nil;
    
    if (url) {
        // Try to get datas from disk
        NSString *directoryPath = cachePath();
        NSString *absoluteURL = [self generateGETAbsoluteURL:url params:params];
        NSString *key = [NSString csNetworking_md5:absoluteURL];
        NSString *path = [directoryPath stringByAppendingPathComponent:key];
        
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        if (data) {
            cacheData = data;
            CSAppLog(@"从缓存中读取网址的数据: %@\n", url);
        }
    }
    
    return cacheData;
}

+ (void)cacheResponseObject:(id)responseObject request:(NSURLRequest *)request parameters:params {
    if (request && responseObject && ![responseObject isKindOfClass:[NSNull class]]) {
        NSString *directoryPath = cachePath();
        
        NSError *error = nil;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                CSAppLog(@"创建缓存dir错误: %@\n", error);
                return;
            }
        }
        
        NSString *absoluteURL = [self generateGETAbsoluteURL:request.URL.absoluteString params:params];
        NSString *key = [NSString csNetworking_md5:absoluteURL];
        NSString *path = [directoryPath stringByAppendingPathComponent:key];
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSData *data = nil;
        if ([dict isKindOfClass:[NSData class]]) {
            data = responseObject;
        } else {
            data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
        }
        
        if (data && error == nil) {
            BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            if (isOk) {
                CSAppLog(@"缓存文件成功! 请求: %@\n", absoluteURL);
            } else {
                CSAppLog(@"缓存文件错误! 请求: %@\n", absoluteURL);
            }
        }
    }
}
//MARK: 根据路径返回绝对URL
+ (NSString *)absoluteUrlWithPath:(NSString *)path {
    if (path == nil || path.length == 0) {
        return @"";
    }
    
    if ([self baseUrl] == nil || [[self baseUrl] length] == 0) {
        return path;
    }
    
    NSString *absoluteUrl = path;
    
    if (![path hasPrefix:@"http://"] && ![path hasPrefix:@"https://"]) {
        absoluteUrl = [NSString stringWithFormat:@"%@%@",
                       [self baseUrl], path];
    }
    
    return absoluteUrl;
}

//MARK:处理回调函数错误
+ (void)handleCallbackWithError:(NSError *)error fail:(CSResponseFail)fail {
    if ([error code] == NSURLErrorCancelled) {
        if (sg_shouldCallbackOnCancelRequest) {
            if (fail) {
                fail(error);
            }
        }
    } else {
        if (fail) {
            fail(error);
        }
    }
}

@end
