//
//  CSImageDecoder.h
//  CSCategory
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/** 图片格式类型 */
typedef NS_ENUM(NSUInteger, CSImageType) {
    CSImageTypeUnknown = 0, ///< unknown
    CSImageTypeJPEG,        ///< jpeg, jpg
    CSImageTypeJPEG2000,    ///< jp2
    CSImageTypeTIFF,        ///< tiff, tif
    CSImageTypeBMP,         ///< bmp
    CSImageTypeICO,         ///< ico
    CSImageTypeICNS,        ///< icns
    CSImageTypeGIF,         ///< gif
    CSImageTypePNG,         ///< png
    CSImageTypeWebP,        ///< webp
    CSImageTypeOther,       ///< other image format
};



/**
 帧过渡方式
 指定在渲染画布上的下一个帧之前如何对当前帧使用的区域进行处理
 
 - CSImageDisposeNone: 在渲染下一帧之前,不要对画布进行处理.就是画布保持原样
 - CSImageDisposeBackground: 在渲染下一帧之前,画布的框架区域将被清除为完全透明的黑色
 - CSImageDisposePrevious: 在渲染下一帧之前,画布的框架区域将被还原为先前的内容
 */
typedef NS_ENUM(NSUInteger, CSImageDisposeMethod) {
    CSImageDisposeNone = 0,
    CSImageDisposeBackground,
    CSImageDisposePrevious,
};


/**
 帧混合类型
 
 - CSImageBlendNone: 帧的当前内容所有颜色轻重,包括alpha,覆盖帧的画布区域
 - CSImageBlendOver: 该帧应该基于其alpha来合成并输出到缓冲区
 */
typedef NS_ENUM(NSUInteger, CSImageBlendOperation) {
    CSImageBlendNone = 0,
    CSImageBlendOver,
};


///MARK: ===================================================
///MARK: 图像帧对象
///MARK: ===================================================
@interface CSImageFrame : NSObject <NSCopying>
@property (nonatomic) NSUInteger index;    ///< 帧索引 (zero based)
@property (nonatomic) NSUInteger width;    ///< Frame width
@property (nonatomic) NSUInteger height;   ///< Frame height
@property (nonatomic) NSUInteger offsetX;  ///< Frame origin.x in canvas (left-bottom based)
@property (nonatomic) NSUInteger offsetY;  ///< Frame origin.y in canvas (left-bottom based)
@property (nonatomic) NSTimeInterval duration;          ///< 帧持续时间
@property (nonatomic) CSImageDisposeMethod dispose;     ///< 帧过渡方式.
@property (nonatomic) CSImageBlendOperation blend;      ///< 帧混合类型.
@property (nullable, nonatomic, strong) UIImage *image; ///< The image.
+ (instancetype)frameWithImage:(UIImage *)image;
@end


///MARK: ===================================================
///MARK: 图像解码器
///MARK: ===================================================

/**
 用于解码图像数据的图像解码器
 
 该类支持解码动画的WebP,APNG,GIF和系统的图像格式,例如PNG,JPG,JP2,BMP,TIFF,PIC,ICNS和ICO.
 它可以用来解码完整的图像数据或图像下载期间的增量图像数据进行解码.这个类是线程安全的
 
 示例代码:
 
 Example:

 // 解码单张图片:
 NSData *data = [NSData dataWithContentOfFile:@"/tmp/image.webp"];
 CSImageDecoder *decoder = [CSImageDecoder decoderWithData:data scale:2.0];
 UIImage image = [decoder frameAtIndex:0 decodeForDisplay:YES].image;
 
 // 在下载过程中解码图像:
 NSMutableData *data = [NSMutableData new];
 CSImageDecoder *decoder = [[CSImageDecoder alloc] initWithScale:2.0];
 
 while(newDataArrived) {
     [data appendData:newData];
     [decoder updateData:data final:NO];
     if (decoder.frameCount > 0) {
         UIImage image = [decoder frameAtIndex:0 decodeForDisplay:YES].image;
         // 逐行显示...
     }
 }
 [decoder updateData:data final:YES];
 UIImage image = [decoder frameAtIndex:0 decodeForDisplay:YES].image;
 // 最终显示...
 
 */
@interface CSImageDecoder : NSObject

@property (nullable, nonatomic, readonly) NSData *data;    ///< 图像数据.
@property (nonatomic, readonly) CSImageType type;          ///< 图像数据类型.
@property (nonatomic, readonly) CGFloat scale;             ///< 图像尺度比例.
@property (nonatomic, readonly) NSUInteger frameCount;     ///< 图片帧数.
@property (nonatomic, readonly) NSUInteger loopCount;      ///< 图像循环计数,0表示无限大.
@property (nonatomic, readonly) NSUInteger width;          ///< 图像画布宽度.
@property (nonatomic, readonly) NSUInteger height;         ///< 图像画布高度.
@property (nonatomic, readonly, getter=isFinalized) BOOL finalized;


/**
 创建一个图像解码器
 
 @param scale 图像的比例
 @return 图像解码器
 */
- (instancetype)initWithScale:(CGFloat)scale NS_DESIGNATED_INITIALIZER;

/**
 使用新数据更新增量映像
 
 当您没有完整的图像数据时,您可以使用此方法(渐进&隔行扫描&基线) 对图像进行解码.
 'data'由解码器保留,您不应在解码过程中修改其他线程中的数据
 
 @param data 要添加到图像解码器的数据.每次调用此函数时,'data'参数必须包含到目前为止累积的所有图像文件数据
 @param final 指定数据是否为最终集的值.如果设置NO,当数据已经完成时,您将无法再更新数据
 @return 是否成功
 */
- (BOOL)updateData:(nullable NSData *)data final:(BOOL)final;


/**
 创建具有指定数据的解码器的便利方法
 
 @param data 图像数据
 @param scale 图像的比例
 @return 解码器,如果发生错误则返回 nil
 */
+ (nullable instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale;


/**
 从指定的索引解码并返回一个帧
 
 @param index 图像索引(zero-based)
 @param decodeForDisplay 是否将图像解码为内存位图进行显示(如果NO,将尝试返回原始帧数据而不进行混合)
 @return 带有图像的新框架,如果发生错误则返回 nil
 */
- (nullable CSImageFrame *)frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay;


/**
 从指定的索引返回帧持续时间
 
 @param index 图像索引(zero-based)
 @return 持续时间(单位秒)
 */
- (NSTimeInterval)frameDurationAtIndex:(NSUInteger)index;


/**
 返回框架的属性.
 有关更多信息,请参阅ImageIO.framework中的'CGImageProperties.h'
 
 @param index 图像帧索引
 @return  imageIO框架属性
 */
- (nullable NSDictionary *)framePropertiesAtIndex:(NSUInteger)index;

/**
 Returns the image's properties. See "CGImageProperties.h" in ImageIO.framework
 for more information.
 */

/**
 返回图像的属性
 有关更多信息,请参阅ImageIO.framework中的'CGImageProperties.h'
 */
- (nullable NSDictionary *)imageProperties;


@end



///MARK: ===================================================
///MARK: 编码器
///MARK: ===================================================

/**
 用于将图像编码到数据的图像编码器.
 
 @discussion
 它支持使用CSImageType中定义的类型编码单帧图像.
 它还支持使用GIF,APNG和WebP编码多帧图像.
 
 示例代码:
 
 CSImageEncoder *jpegEncoder = [[CSImageEncoder alloc] initWithType:CSImageTypeJPEG];
 jpegEncoder.quality = 0.9;
 [jpegEncoder addImage:image duration:0];
 NSData jpegData = [jpegEncoder encode];
 
 CSImageEncoder *gifEncoder = [[CSImageEncoder alloc] initWithType:CSImageTypeGIF];
 gifEncoder.loopCount = 5;
 [gifEncoder addImage:image0 duration:0.1];
 [gifEncoder addImage:image1 duration:0.15];
 [gifEncoder addImage:image2 duration:0.2];
 NSData gifData = [gifEncoder encode];
 
 @warning
 它在编码多帧图像时将图像打包在一起.
 如果要减小图像文件大小,请尝试使用imagemagick/ffmpeg为GIF和WebP,apngasm为APNG..
 */
@interface CSImageEncoder : NSObject

@property (nonatomic, readonly) CSImageType type; ///< 图像类型.
@property (nonatomic) NSUInteger loopCount;       ///< 循环计数,0表示无限大,仅适用于 GIF/APNG/WebP.
@property (nonatomic) BOOL lossless;              ///< 无损,仅适用于WebP.
@property (nonatomic) CGFloat quality;            ///< 压缩质量,0.0~1.0,仅适用于JPG/JP2/WebP.

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 创建一个指定类型的图像编码器.
 @param type 图片类型.
 @return 编码器, 如果发生错误则为nil.
 */
- (nullable instancetype)initWithType:(CSImageType)type NS_DESIGNATED_INITIALIZER;

/**
 将图像添加到编码器.
 @param image    Image.
 @param duration 动画的图像持续时间. 通过0忽略此参数.
 */
- (void)addImage:(UIImage *)image duration:(NSTimeInterval)duration;

/**
 将带有图像数据添加到编码器.
 @param data    Image data.
 @param duration 动画的图像持续时间. 通过0忽略此参数.
 */
- (void)addImageWithData:(NSData *)data duration:(NSTimeInterval)duration;

/**
 将图像从文件路径添加到编码器.
 @param path   图片文件路径.
 @param duration 动画的图像持续时间. 通过0忽略此参数.
 */
- (void)addImageWithFile:(NSString *)path duration:(NSTimeInterval)duration;

/** 对图像进行编码并返回图像数据 如果发生错误则返回 nil */
- (nullable NSData *)encode;


/**
 将图像编码到文件
 
 @param path 文件路径(如果已存在,则覆盖)
 @return 是否成功
 */
- (BOOL)encodeToFile:(NSString *)path;

/**
 编码单个帧图像
 
 @param image 图片
 @param type 图片类型
 @param quality 画面质量(0.0~1.0)
 @return 图片数据,如果发生错误则为nil
 */
+ (nullable NSData *)encodeImage:(UIImage *)image type:(CSImageType)type quality:(CGFloat)quality;

/**
 从解码器编码图像
 
 @param decoder 图像解码器
 @param type 图片类型
 @param quality 画面质量(0.0~1.0)
 @return 图片数据,如果发生错误则为nil
 */
+ (nullable NSData *)encodeImageWithDecoder:(CSImageDecoder *)decoder type:(CSImageType)type quality:(CGFloat)quality;

@end










///MARK: ===================================================
///MARK: 图片额外操作分类
///MARK: ===================================================
@interface UIImage (CSImageCoder)

/**
 将此图像解压缩到位图,因此当图像显示在屏幕上时,主线程不会被附加解码阻止.
 如果图像已被解码或无法解码,则只返回自身.
 
 @return 图像被解码,或者如果不需要,就返回自己
 */
- (instancetype)imageByDecoded;

/**
 是否可以直接显示,无需额外解码
 @warning 它只是为你的代码提示,改变它没有其他作用.
 */
@property (nonatomic) BOOL isDecodedForDisplay;


/**
 将此图像保存到iOS相册
 
 如果从动画GIF/APNG创建图像,则此方法会尝试将原始数据保存到相册,否则会将图像保存为JPEG或PNG(基于Alpha信息)
 
 @param completionBlock 保存操作完成后调用块,基于主线程.(assetURL:标识保存的图像文件的URL;error:错误反馈)
 */
- (void)saveToAlbumWithCompletionBlock:(nullable void(^)(NSURL * _Nullable assetURL, NSError * _Nullable error))completionBlock;


/**
 为此图片返回'最佳'质量数据
 
 基于这些规则的转换:
 1.如果图像是从动画GIF/APNG/WebP创建的,则返回原始数据.
 2.它基于alpha信息返回PNG或JPEG(0.9)表示
 
 @return 图片数据
 */
- (nullable NSData *)imageDataRepresentation;

@end










///MARK: ===================================================
///MARK: 助手函数
///MARK: ===================================================
///MARK: 通过读取数据的头16字节(非常快)来检测数据的图片类型
CG_EXTERN CSImageType CSImageDetectType(CFDataRef data);
///MARK: 将CSImageType转换为UTI(如kUTTypeJPEG)
CG_EXTERN CFStringRef _Nullable CSImageTypeToUTType(CSImageType type);
///MARK: 将UTI(例如kUTTypeJPEG)转换为CSImageType
CG_EXTERN CSImageType CSImageTypeFromUTType(CFStringRef uti);
///MARK: 获取图片类型的文件扩展名(如@“jpg”).
CG_EXTERN NSString *_Nullable CSImageTypeGetExtension(CSImageType type);
///MARK: 返回共享的DeviceRGB颜色空间
CG_EXTERN CGColorSpaceRef CSCGColorSpaceGetDeviceRGB();
///MARK: 返回共享的DeviceGray颜色空间
CG_EXTERN CGColorSpaceRef CSCGColorSpaceGetDeviceGray();
///MARK: 返回颜色空间是否为DeviceRGB
CG_EXTERN BOOL CSCGColorSpaceIsDeviceRGB(CGColorSpaceRef space);
///MARK: 返回颜色空间是否为DeviceGray
CG_EXTERN BOOL CSCGColorSpaceIsDeviceGray(CGColorSpaceRef space);
///MARK: 转换EXIF取向值为UIImageOrientation
CG_EXTERN UIImageOrientation CSUIImageOrientationFromEXIFValue(NSInteger value);
///MARK: 将UIImageOrientation转换为EXIF方向值
CG_EXTERN NSInteger CSUIImageOrientationToEXIFValue(UIImageOrientation orientation);


/**
 创建一个解码的图像
 
 如果源图像是从压缩图像数据(如PNG或JPEG)创建的,则可以使用此方法对图像进行解码.
 解码后,您可以使用CGImageGetDataProvider()和CGDataProviderCopyData()访问解码的字节,无需额外的解码过程.
 如果图像已经被解码,则该方法仅将解码的字节复制到新图像
 
 @param imageRef            源图像
 @param decodeForDisplay    如果YES,则该方法将对图像进行解码,并将其转换为BGRA8888(预乘)或BGRX8888格式用于CALayer显示
 @return                    解码图像,如果发生错误,则返回NULL
 */
CG_EXTERN CGImageRef _Nullable CSCGImageCreateDecodedCopy(CGImageRef imageRef, BOOL decodeForDisplay);


/**
 创建一个具有方向的图像副本
 
 @param imageRef        源图像
 @param orientation     将应用于图像的图像方向
 @param destBitmapInfo  图像位图,只支持32bit格式(如ARGB8888)
 @return                新图像,如果发生错误则为NULL
 */
CG_EXTERN CGImageRef _Nullable CSCGImageCreateCopyWithOrientation(CGImageRef imageRef,
                                                                  UIImageOrientation orientation,
                                                                  CGBitmapInfo destBitmapInfo);

/**
 使用CGAffineTransform创建图像副本
 
 @param imageRef        源图像
 @param transform       形变参数(基于左下角的坐标系)
 @param destSize        目标图像大小
 @param destBitmapInfo  图像位图,只支持32bit格式(如ARGB8888)
 @return                新图像,如果发生错误则为NULL
 */
CG_EXTERN CGImageRef _Nullable CSCGImageCreateAffineTransformCopy(CGImageRef imageRef,
                                                                  CGAffineTransform transform,
                                                                  CGSize destSize,
                                                                  CGBitmapInfo destBitmapInfo);

/**
 使用CGImageDestination编码图像到数据
 
 @param imageRef    源图像
 @param type        图像类型
 @param quality     图片质量(0.0~1.0)
 @return            新图像,如果发生错误则返回 NULL
 */
CG_EXTERN CFDataRef _Nullable CSCGImageCreateEncodedData(CGImageRef imageRef, CSImageType type, CGFloat quality);


/**
 WebP是否可用于CSImage.
 */
CG_EXTERN BOOL CSImageWebPAvailable();


/**
 获取webp图像帧数
 
 @param webpData WebP数据
 @return 图像帧计数,如果发生错误则为0
 */
CG_EXTERN NSUInteger CSImageGetWebPFrameCount(CFDataRef webpData);


/**
 从WebP数据解码图像,如果发生错误,则返回NULL
 
 @param webpData            WebP数据
 @param decodeForDisplay    如果YES,该方法将解码图像并进行转换至CALAGE显示的BGRA8888(预乘)格式
 @param useThreads          如果YES,启用多线程解码. (加快,但成本更高的CPU)
 @param bypassFiltering     如果YES,跳过循环过滤. (加快,但可能会失去一些光滑)
 @param noFancyUpsampling   如果YES,使用更快的点式上采样器. (速度下降,可能会丢失一些细节)
 @return                    解码的图像,如果发生错误则为NULL
 */
CG_EXTERN CGImageRef _Nullable CSCGImageCreateWithWebPData(CFDataRef webpData,
                                                           BOOL decodeForDisplay,
                                                           BOOL useThreads,
                                                           BOOL bypassFiltering,
                                                           BOOL noFancyUpsampling);

typedef NS_ENUM(NSUInteger, CSImagePreset) {
    CSImagePresetDefault = 0,  ///< 默认预设.
    CSImagePresetPicture,      ///< 数字图像,如肖像,室内拍摄
    CSImagePresetPhoto,        ///< 户外照片,具有自然采光
    CSImagePresetDrawing,      ///< 手绘线条图,具有高对比度的细节
    CSImagePresetIcon,         ///< 小尺寸彩色图像
    CSImagePresetText          ///< 文字图像
};


/**
 将CGImage编码到WebP数据
 
 @param imageRef        源图像
 @param lossless        YES = lossless(类似于PNG),NO = 有损(类似于JPEG)
 @param quality         质量 0.0~1.0(0 =最小文件,1.0 =最大文件) 对于无损图像,请尝试1.0附近的值; 为了有损,尝试接近0.8附近的价值
 @param compressLevel   压缩级别 0~6(0 = 快,6 = 慢 - 更好). 默认值为4
 @param preset          预设为不同的图像类型预设,默认为CSImagePresetDefault
 @return                WebP数据, 如果发生错误则为nil
 */
CG_EXTERN CFDataRef _Nullable CSCGImageCreateEncodedWebPData(CGImageRef imageRef,
                                                             BOOL lossless,
                                                             CGFloat quality,
                                                             int compressLevel,
                                                             CSImagePreset preset);







NS_ASSUME_NONNULL_END




