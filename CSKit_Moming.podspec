#  运行'pod spec lint CSKit.podspec'前确保这是一个有效的规范,并在提交规范之前删除包括这些在内的所有备注

Pod::Spec.new do |s|

# ―――  元数据规范   ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  这些信息将帮助别人找到您的库,一下信息可以简单描述你的库,让人更加简单的了解你的库文件.摘要应该是tweet-length,并且描述更深入.
#

s.name         = "CSKit_Moming"
s.version      = "1.1.7"
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
s.platform       = :ios, "8.2"

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
#"CSKit/CSKit/CSKit/Cache/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSBaseClass/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSPopupController/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSPopupController/Classes/CustomView/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSIndicator/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSNotificationIndicator/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSProgressIndicator/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSToastIndicator/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Category/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Model/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/View/*" ,
#"CSKit/CSKit/CSKit/CustomClass/CSPhotoGroupView/*" ,
#"CSKit/CSKit/CSKit/CustomClass/UITableViewProtocol/*" ,
#"CSKit/CSKit/CSKit/Extended/Foundation/*" ,
#"CSKit/CSKit/CSKit/Extended/Macro/*" ,
#"CSKit/CSKit/CSKit/Extended/Quartz/*" ,
#"CSKit/CSKit/CSKit/Extended/UIKit/*" ,
#"CSKit/CSKit/CSKit/Image/*" ,
#"CSKit/CSKit/CSKit/Image/Categories/*" ,
#"CSKit/CSKit/CSKit/Model/*" ,
#"CSKit/CSKit/CSKit/Model/Unicode/*" ,
#"CSKit/CSKit/CSKit/Text/Component/*" ,
#"CSKit/CSKit/CSKit/Text/String/*" ,
#"CSKit/CSKit/CSKit/Text/UseClass/*" ,
#"CSKit/CSKit/CSKit/Utility/*" ,




s.source_files   =  "CSKit/CSKit/CSKit/*"
s.public_header_files = 'CSKit/CSKit/CSKit/*.{h}'


s.subspec 'Base' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/Base/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/Base/*.{h}'
end


s.subspec 'Cache' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/Cache/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/Cache/*.{h}'
end


s.subspec 'CSBaseClass' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSBaseClass/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSBaseClass/*.{h}'
end



s.subspec 'CSPopupController' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSPopupController/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSPopupController/*.{h}'
    ss.subspec 'CustomView' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSPopupController/Classes/CustomView/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSPopupController/Classes/CustomView/*.{h}'
    end
end




s.subspec 'CSIndicator' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/*.{h}'
    ss.subspec 'CSNotificationIndicator' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSNotificationIndicator/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSNotificationIndicator/*.{h}'
    end
    ss.subspec 'CSProgressIndicator' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSProgressIndicator/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSProgressIndicator/*.{h}'
    end
    ss.subspec 'CSToastIndicator' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSToastIndicator/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSToastIndicator/*.{h}'
    end
end



s.subspec 'CSImageBrowser' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/*.{h}'
    ss.subspec 'Category' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Category/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Category/*.{h}'
    end
    ss.subspec 'Model' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Model/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Model/*.{h}'
    end
    ss.subspec 'View' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/View/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/View/*.{h}'
    end
end




s.subspec 'CSPhotoGroupView' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSPhotoGroupView/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/CSPhotoGroupView/*.{h}'
end


s.subspec 'UITableViewProtocol' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/CustomClass/UITableViewProtocol/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/CustomClass/UITableViewProtocol/*.{h}'
end


s.subspec 'Utility' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/Utility/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/Utility/*.{h}'
end

s.subspec 'Text' do |ss|
    ss.subspec 'Component' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/Text/Component/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/Text/Component/*.{h}'
    end
    ss.subspec 'String' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/Text/String/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/Text/String/*.{h}'
    end
    ss.subspec 'UseClass' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/Text/UseClass/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/Text/UseClass/*.{h}'
    end
end


s.subspec 'Model' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/Model/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/Model/*.{h}'
    ss.subspec 'Unicode' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/Model/Unicode/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/Model/Unicode/*.{h}'
    end
end



s.subspec 'Image' do |ss|
    ss.source_files = 'CSKit/CSKit/CSKit/Image/*'
    ss.public_header_files = 'CSKit/CSKit/CSKit/Image/*.{h}'
    ss.subspec 'Categories' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/Image/Categories/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/Image/Categories/*.{h}'
    end
end



s.subspec 'Extended' do |ss|
    ss.subspec 'Foundation' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/Extended/Foundation/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/Extended/Foundation/*.{h}'
    end
    ss.subspec 'Quartz' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/Extended/Quartz/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/Extended/Quartz/*.{h}'
    end
    ss.subspec 'UIKit' do |sss|
        sss.source_files = 'CSKit/CSKit/CSKit/Extended/UIKit/*'
        sss.public_header_files = 'CSKit/CSKit/CSKit/Extended/UIKit/*.{h}'
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
