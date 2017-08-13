#  运行'pod spec lint CSKit.podspec'前确保这是一个有效的规范,并在提交规范之前删除包括这些在内的所有备注

Pod::Spec.new do |s|

# ―――  元数据规范   ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  这些信息将帮助别人找到您的库,一下信息可以简单描述你的库,让人更加简单的了解你的库文件.摘要应该是tweet-length,并且描述更深入.
#

    s.name         = "CSKit_Moming"
    s.version      = "1.1.4"
    s.summary      = "CSKit.Integration of some commonly used tools and controls,Write it casually."

# 此描述用于生成标签并改进搜索结果.
#   * 想想:做什么?你为什么写这个库,什么是焦点?
#   * 尽量保持短暂,快速,至关重要.
#   * 在下面的DESC分隔符之间写下描述.
#   * 不用担心缩进,CocoaPods吧!
    s.description  = <<-DESC
    CSKit.Integration of some commonly used tools and controls,Write it casually,Look at yourself.
    DESC

    s.homepage      = "https://github.com/liuconglaile/CSKit"


# ―――  许可证规范   ―――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  许可你的代码很重要. 有关更多信息,请参阅http://choosealicense.com.
#  CocoaPods将检测到一个许可证文件,如果有一个命名为LICENSE* 的文件
#  常用的许可证为 'MIT', 'BSD' 和 'Apache License, Version 2.0'.
#

    s.license        = "MIT"
# s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


# ――― 作者元数据   ―――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  用电子邮件地址指定库的作者.作者的电子邮件地址从SCM日志中提取。
#  例如.$ git log. 如果您不想提供电子邮件地址,CocoaPods也会接受一个名称
#  指定其他人可以参考的social_media_url,例如twitter个人资料网址.
#

    s.author             = { "Moming" => "281090013@qq.com" }
# Or just: s.author    = "Moming"
# s.authors            = { "Moming" => "281090013@qq.com" }
# s.social_media_url   = "http://twitter.com/Moming"

# ――― 库平台细节  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  如果此Pod仅在iOS或OS X上运行,则指定平台和部署目标.您可以选择在平台后包括目标.
#

# s.platform     = :ios
    s.platform       = :ios, "8.4"

#  When using multiple platforms
# s.ios.deployment_target = "5.0"
# s.osx.deployment_target = "10.7"
# s.watchos.deployment_target = "2.0"
# s.tvos.deployment_target = "9.0"


# ――― 来源地点  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  指定来源应从哪里检索的位置.
#  支持 git, hg, bzr, svn 和 HTTP.
#

    s.source       = { :git => "https://github.com/liuconglaile/CSKit.git", :tag => "#{s.version}" }


# ――― 源代码  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  CocoaPods是如何包含源代码的.
#  给出文件夹的源文件将包括任何swift,h,m,mm,c和cpp文件.
#  对于头文件,它将包括文件夹中的任何标题.
#  不包括public_header_files将使所有标题公开.
#

#s.source_files   =  "CSKit/CSKit/CSKit/*" ,
#                    "CSKit/CSKit/CSKit/Cache/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSBaseClass/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSNetworkTools/CSNetworkTopMaskView/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSNetworkTools/CSNetworkTopMaskView/Model/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSPopupController/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSPopupController/Classes/CustomView/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSIndicator/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSNotificationIndicator/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSProgressIndicator/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSToastIndicator/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Category/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Model/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/View/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/CSPhotoGroupView/*" ,
#                    "CSKit/CSKit/CSKit/CustomClass/UITableViewProtocol/*" ,
#                    "CSKit/CSKit/CSKit/Extended/Foundation/*" ,
#                    "CSKit/CSKit/CSKit/Extended/Macro/*" ,
#                    "CSKit/CSKit/CSKit/Extended/Quartz/*" ,
#                    "CSKit/CSKit/CSKit/Extended/UIKit/*" ,
#                    "CSKit/CSKit/CSKit/Image/*" ,
#                    "CSKit/CSKit/CSKit/Image/Categories/*" ,
#                    "CSKit/CSKit/CSKit/Model/*" ,
#                    "CSKit/CSKit/CSKit/Model/Unicode/*" ,
#                    "CSKit/CSKit/CSKit/Text/Component/*" ,
#                    "CSKit/CSKit/CSKit/Text/String/*" ,
#                    "CSKit/CSKit/CSKit/Text/UseClass/*" ,
#                    "CSKit/CSKit/CSKit/Utility/*" ,


s.subspec 'CSKit' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/*.{h,m}'


    # 常用
    ss.subspec 'Utility' do | sss |
        sss.source_files = 'CSKit/CSKit/CSKit/Utility/*.{h,m}'
    end


    # 文本
    ss.subspec 'Text' do | sss |
        sss.subspec 'Component' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/Text/Component/*.{h,m}'
        end

        sss.subspec 'String' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/Text/String/*.{h,m}'
        end

        sss.subspec 'UseClass' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/Text/UseClass/*.{h,m}'
        end
    end


    # 模型
    ss.subspec 'Model' do | sss |
        sss.source_files = 'CSKit/CSKit/CSKit/Model/*.{h,m}'

        sss.subspec 'Unicode' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/Model/Unicode/*.{h,m}'
        end
    end



    # 图片
    ss.subspec 'Image' do | sss |
        sss.source_files = 'CSKit/CSKit/CSKit/Image/*.{h,m}'

        sss.subspec 'Categories' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/Image/Categories/*.{h,m}'
        end
    end


    # 分类
    ss.subspec 'Extended' do | sss |

        sss.subspec 'Foundation' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/Extended/Foundation/*.{h,m}'
        end

        sss.subspec 'Macro' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/Extended/Macro/*.{h,m}'
        end

        sss.subspec 'Quartz' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/Extended/Quartz/*.{h,m}'
        end

        sss.subspec 'UIKit' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/Extended/UIKit/*.{h,m}'
        end

    end




    # 缓存
    ss.subspec 'Cache' do | sss |
        sss.source_files = 'CSKit/CSKit/CSKit/Cache/*.{h,m}'
    end





    # 自定义类
    ss.subspec 'CustomClass' do | sss |




        # UITableView封装
        sss.subspec 'UITableViewProtocol' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/UITableViewProtocol/*.{h,m}'
        end

        # 图片浏览器1
        sss.subspec 'CSImageBrowser' do | ssss |

            ssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/*.{h,m}'

            ssss.subspec 'Category' do | sssss |
                sssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Category/*.{h,m}'
            end

            ssss.subspec 'Model' do | sssss |
                sssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Model/*.{h,m}'
            end

            ssss.subspec 'View' do | sssss |
                sssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/View/*.{h,m}'
            end
        end

        # 图片浏览器2
        sss.subspec 'CSPhotoGroupView' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSPhotoGroupView/*.{h,m}'
        end


        # 基类
        sss.subspec 'CSBaseClass' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSBaseClass/*.{h,m}'
        end


        # 请求库
        sss.subspec 'CSNetworkTools' do | ssss |
            ssss.subspec 'CSNetworkTopMaskView' do | sssss |

                sssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSNetworkTools/CSNetworkTopMaskView/*.{h,m}'

                sssss.subspec 'Model' do | ssssss |
                    ssssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSNetworkTools/CSNetworkTopMaskView/Model/*.{h,m}'
                    ssssss.resource     = 'CSKit/CSKit/CSKit/CustomClass/CSNetworkTools/CSNetworkTopMaskView/CSNetworkTools.bundle'
                end
            end
        end


        # modal 工具
        sss.subspec 'CSPopupController' do | ssss |
            ssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSPopupController/*.{h,m}'
            ssss.subspec 'CustomView' do | sssss |
                sssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSPopupController/Classes/CustomView/*.{h,m}'
            end
        end


        # 指示器
        sss.subspec 'CSIndicator' do | ssss |

            ssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/*.{h,m}'

            ssss.subspec 'CSNotificationIndicator' do | sssss |
                sssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSNotificationIndicator/*.{h,m}'
            end

            ssss.subspec 'CSProgressIndicator' do | sssss |
                sssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSProgressIndicator/*.{h,m}'
                sssss.resource     = 'CSKit/CSKit/CustomClass/CSIndicator/CSProgressIndicator/CSProgressIndicatorImage.bundle'
            end

            ssss.subspec 'CSToastIndicator' do | sssss |
                sssss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSToastIndicator/*.{h,m}'
            end
        end
    end

end
















#s.exclude_files = "CSKit/CSKit"

# s.public_header_files = "Classes/**/*.h"


# ――― 资源  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  Pod包含的资源列表.这些将使用构建阶段脚本复制到目标包中.其他任何东西都会被清理.
#  您可以保护文件不被清理,请勿保留非必要文件,如测试,示例和文档.
#

# s.resource  = "icon.png"
# s.resources = "Resources/*.png"

# s.preserve_paths = "FilesToSave", "MoreFilesToSave"


# ――― 项目链接  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  将库与框架或库链接起来.库不包括其名称的lib前缀,如 libsqlite3 ==> sqlite3.
#

s.framework    = "CoreText"
# s.frameworks = "CoreText", "libsqlite3", "libz"

# s.library    = "iconv"
s.libraries    = "sqlite3", "z"


# ――― 项目设置 ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  如果你的库依赖于编译器标志，你可以在xcconfig哈希中设置它们
#  该设置只适用于你的库.如果你依赖其他Podspecs你可以包括多个依赖关系,以确保它有效

    s.requires_arc = true

# s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
    s.dependency "AFNetworking"
    s.dependency "MJRefresh"

end
