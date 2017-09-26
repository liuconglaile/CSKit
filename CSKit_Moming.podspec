Pod::Spec.new do |s|

s.name         = "CSKit_Moming"
s.version      = "1.2.2"
s.summary      = "CSKit.Integration of some commonly used tools and controls,Write it casually."
s.homepage      = "https://github.com/liuconglaile/CSKit"
s.license        = "MIT"
s.author             = { "Moming" => "281090013@qq.com" }
s.description  = <<-DESC
CSKit.Integration of some commonly used tools and controls,Write it casually,Look at yourself.
DESC


s.platform       = :ios, "8.2"
s.source       = { :git => "https://github.com/liuconglaile/CSKit.git", :tag => "#{s.version}" }
s.source_files   =  "CSKit/CSKit/CSKit/**/*"
s.public_header_files = 'CSKit/CSKit/CSKit/**/*.{h}'
s.libraries    = "sqlite3", "z"
s.requires_arc = true
s.dependency "AFNetworking"
s.dependency "MJRefresh"





s.subspec 'CSkit' do |ss|

    ss.dependency 'CSkit/Base'
    ss.dependency 'CSkit/Cache'
    ss.dependency 'CSkit/Utility'

    ss.dependency 'CSkit/Text/Component'
    ss.dependency 'CSkit/Text/String'
    ss.dependency 'CSkit/Text/UseClass'

    ss.dependency 'CSkit/Model'
    ss.dependency 'CSkit/Model/Unicode'

    ss.dependency 'CSkit/Image'
    ss.dependency 'CSkit/Image/Categories'

    ss.dependency 'CSkit/Extended/Foundation'
    ss.dependency 'CSkit/Extended/Quartz'
    ss.dependency 'CSkit/Extended/UIKit'

    ss.dependency 'CSkit/CustomClass/CSBaseClass'

    ss.dependency 'CSkit/CustomClass/CSNetworkTools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

    ss.dependency 'CSkit/CustomClass/CSPopupController'
    ss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


    ss.dependency 'CSkit/CustomClass/CSIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


    ss.dependency 'CSkit/CustomClass/CSImageBrowser'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


    ss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

    ss.dependency 'CSkit/CustomClass/UITableViewProtocol'

end


s.subspec 'Base' do |ss|

    ss.dependency 'CSkit/Base'
    ss.dependency 'CSkit/Cache'
    ss.dependency 'CSkit/Utility'

    ss.dependency 'CSkit/Text/Component'
    ss.dependency 'CSkit/Text/String'
    ss.dependency 'CSkit/Text/UseClass'

    ss.dependency 'CSkit/Model'
    ss.dependency 'CSkit/Model/Unicode'

    ss.dependency 'CSkit/Image'
    ss.dependency 'CSkit/Image/Categories'

    ss.dependency 'CSkit/Extended/Foundation'
    ss.dependency 'CSkit/Extended/Quartz'
    ss.dependency 'CSkit/Extended/UIKit'

    ss.dependency 'CSkit/CustomClass/CSBaseClass'

    ss.dependency 'CSkit/CustomClass/CSNetworkTools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

    ss.dependency 'CSkit/CustomClass/CSPopupController'
    ss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


    ss.dependency 'CSkit/CustomClass/CSIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


    ss.dependency 'CSkit/CustomClass/CSImageBrowser'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


    ss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

    ss.dependency 'CSkit/CustomClass/UITableViewProtocol'
    ss.source_files = 'CSKit/CSKit/CSKit/Base/*.{h,m}'



end


s.subspec 'Cache' do |ss|

    ss.dependency 'CSkit/Base'
    ss.dependency 'CSkit/Cache'
    ss.dependency 'CSkit/Utility'

    ss.dependency 'CSkit/Text/Component'
    ss.dependency 'CSkit/Text/String'
    ss.dependency 'CSkit/Text/UseClass'

    ss.dependency 'CSkit/Model'
    ss.dependency 'CSkit/Model/Unicode'

    ss.dependency 'CSkit/Image'
    ss.dependency 'CSkit/Image/Categories'

    ss.dependency 'CSkit/Extended/Foundation'
    ss.dependency 'CSkit/Extended/Quartz'
    ss.dependency 'CSkit/Extended/UIKit'

    ss.dependency 'CSkit/CustomClass/CSBaseClass'

    ss.dependency 'CSkit/CustomClass/CSNetworkTools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

    ss.dependency 'CSkit/CustomClass/CSPopupController'
    ss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


    ss.dependency 'CSkit/CustomClass/CSIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


    ss.dependency 'CSkit/CustomClass/CSImageBrowser'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


    ss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

    ss.dependency 'CSkit/CustomClass/UITableViewProtocol'
    ss.source_files = 'CSKit/CSKit/CSKit/Cache/*.{h,m}'



end


s.subspec 'Utility' do |ss|

    ss.dependency 'CSkit/Base'
    ss.dependency 'CSkit/Cache'
    ss.dependency 'CSkit/Utility'

    ss.dependency 'CSkit/Text/Component'
    ss.dependency 'CSkit/Text/String'
    ss.dependency 'CSkit/Text/UseClass'

    ss.dependency 'CSkit/Model'
    ss.dependency 'CSkit/Model/Unicode'

    ss.dependency 'CSkit/Image'
    ss.dependency 'CSkit/Image/Categories'

    ss.dependency 'CSkit/Extended/Foundation'
    ss.dependency 'CSkit/Extended/Quartz'
    ss.dependency 'CSkit/Extended/UIKit'

    ss.dependency 'CSkit/CustomClass/CSBaseClass'

    ss.dependency 'CSkit/CustomClass/CSNetworkTools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

    ss.dependency 'CSkit/CustomClass/CSPopupController'
    ss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


    ss.dependency 'CSkit/CustomClass/CSIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


    ss.dependency 'CSkit/CustomClass/CSImageBrowser'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


    ss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

    ss.dependency 'CSkit/CustomClass/UITableViewProtocol'
    ss.source_files = 'CSKit/CSKit/CSKit/Utility/*.{h,m}'



end


s.subspec 'Text' do |ss|

    ss.dependency 'CSkit/Base'
    ss.dependency 'CSkit/Cache'
    ss.dependency 'CSkit/Utility'

    ss.dependency 'CSkit/Text/Component'
    ss.dependency 'CSkit/Text/String'
    ss.dependency 'CSkit/Text/UseClass'

    ss.dependency 'CSkit/Model'
    ss.dependency 'CSkit/Model/Unicode'

    ss.dependency 'CSkit/Image'
    ss.dependency 'CSkit/Image/Categories'

    ss.dependency 'CSkit/Extended/Foundation'
    ss.dependency 'CSkit/Extended/Quartz'
    ss.dependency 'CSkit/Extended/UIKit'

    ss.dependency 'CSkit/CustomClass/CSBaseClass'

    ss.dependency 'CSkit/CustomClass/CSNetworkTools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

    ss.dependency 'CSkit/CustomClass/CSPopupController'
    ss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


    ss.dependency 'CSkit/CustomClass/CSIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


    ss.dependency 'CSkit/CustomClass/CSImageBrowser'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


    ss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

    ss.dependency 'CSkit/CustomClass/UITableViewProtocol'
    ss.source_files = 'CSKit/CSKit/CSKit/Text/Component/*.{h,m}','CSKit/CSKit/CSKit/Text/String/*.{h,m}','CSKit/CSKit/CSKit/Text/UseClass/*.{h,m}'

end


s.subspec 'Model' do |ss|

    ss.dependency 'CSkit/Base'
    ss.dependency 'CSkit/Cache'
    ss.dependency 'CSkit/Utility'

    ss.dependency 'CSkit/Text/Component'
    ss.dependency 'CSkit/Text/String'
    ss.dependency 'CSkit/Text/UseClass'

    ss.dependency 'CSkit/Model'
    ss.dependency 'CSkit/Model/Unicode'

    ss.dependency 'CSkit/Image'
    ss.dependency 'CSkit/Image/Categories'

    ss.dependency 'CSkit/Extended/Foundation'
    ss.dependency 'CSkit/Extended/Quartz'
    ss.dependency 'CSkit/Extended/UIKit'

    ss.dependency 'CSkit/CustomClass/CSBaseClass'

    ss.dependency 'CSkit/CustomClass/CSNetworkTools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

    ss.dependency 'CSkit/CustomClass/CSPopupController'
    ss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


    ss.dependency 'CSkit/CustomClass/CSIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


    ss.dependency 'CSkit/CustomClass/CSImageBrowser'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


    ss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

    ss.dependency 'CSkit/CustomClass/UITableViewProtocol'
    ss.source_files = 'CSKit/CSKit/CSKit/Model/*.{h,m}','CSKit/CSKit/CSKit/Model/Unicode/*.{h,m}'

end


s.subspec 'Image' do |ss|


    ss.dependency 'CSkit/Base'
    ss.dependency 'CSkit/Cache'
    ss.dependency 'CSkit/Utility'

    ss.dependency 'CSkit/Text/Component'
    ss.dependency 'CSkit/Text/String'
    ss.dependency 'CSkit/Text/UseClass'

    ss.dependency 'CSkit/Model'
    ss.dependency 'CSkit/Model/Unicode'

    ss.dependency 'CSkit/Image'
    ss.dependency 'CSkit/Image/Categories'

    ss.dependency 'CSkit/Extended/Foundation'
    ss.dependency 'CSkit/Extended/Quartz'
    ss.dependency 'CSkit/Extended/UIKit'

    ss.dependency 'CSkit/CustomClass/CSBaseClass'

    ss.dependency 'CSkit/CustomClass/CSNetworkTools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

    ss.dependency 'CSkit/CustomClass/CSPopupController'
    ss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


    ss.dependency 'CSkit/CustomClass/CSIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


    ss.dependency 'CSkit/CustomClass/CSImageBrowser'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


    ss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

    ss.dependency 'CSkit/CustomClass/UITableViewProtocol'
    ss.source_files = 'CSKit/CSKit/CSKit/Image/*.{h,m}','CSKit/CSKit/CSKit/Image/Categories/*.{h,m}'

end


s.subspec 'Extended' do |ss|


    ss.dependency 'CSkit/Base'
    ss.dependency 'CSkit/Cache'
    ss.dependency 'CSkit/Utility'

    ss.dependency 'CSkit/Text/Component'
    ss.dependency 'CSkit/Text/String'
    ss.dependency 'CSkit/Text/UseClass'

    ss.dependency 'CSkit/Model'
    ss.dependency 'CSkit/Model/Unicode'

    ss.dependency 'CSkit/Image'
    ss.dependency 'CSkit/Image/Categories'

    ss.dependency 'CSkit/Extended/Foundation'
    ss.dependency 'CSkit/Extended/Quartz'
    ss.dependency 'CSkit/Extended/UIKit'

    ss.dependency 'CSkit/CustomClass/CSBaseClass'

    ss.dependency 'CSkit/CustomClass/CSNetworkTools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
    ss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

    ss.dependency 'CSkit/CustomClass/CSPopupController'
    ss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


    ss.dependency 'CSkit/CustomClass/CSIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
    ss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


    ss.dependency 'CSkit/CustomClass/CSImageBrowser'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
    ss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


    ss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

    ss.dependency 'CSkit/CustomClass/UITableViewProtocol'

    ss.source_files = 'CSKit/CSKit/CSKit/Extended/Foundation/*.{h,m}','CSKit/CSKit/CSKit/Extended/Quartz/*.{h,m}','CSKit/CSKit/CSKit/Extended/UIKit/*.{h,m}'

end


s.subspec 'CustomClass' do |ss|

    ss.subspec 'CSBaseClass' do |sss|

        sss.dependency 'CSkit/Base'
        sss.dependency 'CSkit/Cache'
        sss.dependency 'CSkit/Utility'

        sss.dependency 'CSkit/Text/Component'
        sss.dependency 'CSkit/Text/String'
        sss.dependency 'CSkit/Text/UseClass'

        sss.dependency 'CSkit/Model'
        sss.dependency 'CSkit/Model/Unicode'

        sss.dependency 'CSkit/Image'
        sss.dependency 'CSkit/Image/Categories'

        sss.dependency 'CSkit/Extended/Foundation'
        sss.dependency 'CSkit/Extended/Quartz'
        sss.dependency 'CSkit/Extended/UIKit'

        sss.dependency 'CSkit/CustomClass/CSBaseClass'

        sss.dependency 'CSkit/CustomClass/CSNetworkTools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

        sss.dependency 'CSkit/CustomClass/CSPopupController'
        sss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


        sss.dependency 'CSkit/CustomClass/CSIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


        sss.dependency 'CSkit/CustomClass/CSImageBrowser'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


        sss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

        sss.dependency 'CSkit/CustomClass/UITableViewProtocol'



        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSBaseClass/*.{h,m}'

    end



    ss.subspec 'CSNetworkTools' do |sss|

        sss.dependency 'CSkit/Base'
        sss.dependency 'CSkit/Cache'
        sss.dependency 'CSkit/Utility'

        sss.dependency 'CSkit/Text/Component'
        sss.dependency 'CSkit/Text/String'
        sss.dependency 'CSkit/Text/UseClass'

        sss.dependency 'CSkit/Model'
        sss.dependency 'CSkit/Model/Unicode'

        sss.dependency 'CSkit/Image'
        sss.dependency 'CSkit/Image/Categories'

        sss.dependency 'CSkit/Extended/Foundation'
        sss.dependency 'CSkit/Extended/Quartz'
        sss.dependency 'CSkit/Extended/UIKit'

        sss.dependency 'CSkit/CustomClass/CSBaseClass'

        sss.dependency 'CSkit/CustomClass/CSNetworkTools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

        sss.dependency 'CSkit/CustomClass/CSPopupController'
        sss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


        sss.dependency 'CSkit/CustomClass/CSIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


        sss.dependency 'CSkit/CustomClass/CSImageBrowser'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


        sss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

        sss.dependency 'CSkit/CustomClass/UITableViewProtocol'



        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSNetworkTools/Tools/*.{h,m}','CSKit/CSKit/CSKit/CustomClass/CSNetworkTools/Model/*.{h,m}','CSKit/CSKit/CSKit/CustomClass/CSNetworkTools/CSNetworkTopMaskView/*.{h,m}'

    end



    ss.subspec 'CSPopupController' do |sss|

        sss.dependency 'CSkit/Base'
        sss.dependency 'CSkit/Cache'
        sss.dependency 'CSkit/Utility'

        sss.dependency 'CSkit/Text/Component'
        sss.dependency 'CSkit/Text/String'
        sss.dependency 'CSkit/Text/UseClass'

        sss.dependency 'CSkit/Model'
        sss.dependency 'CSkit/Model/Unicode'

        sss.dependency 'CSkit/Image'
        sss.dependency 'CSkit/Image/Categories'

        sss.dependency 'CSkit/Extended/Foundation'
        sss.dependency 'CSkit/Extended/Quartz'
        sss.dependency 'CSkit/Extended/UIKit'

        sss.dependency 'CSkit/CustomClass/CSBaseClass'

        sss.dependency 'CSkit/CustomClass/CSNetworkTools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

        sss.dependency 'CSkit/CustomClass/CSPopupController'
        sss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


        sss.dependency 'CSkit/CustomClass/CSIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


        sss.dependency 'CSkit/CustomClass/CSImageBrowser'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


        sss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

        sss.dependency 'CSkit/CustomClass/UITableViewProtocol'



        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSPopupController/*.{h,m}','CSKit/CSKit/CSKit/CustomClass/CSPopupController/Classes/CustomView/*.{h,m}'

    end



    ss.subspec 'CSIndicator' do |sss|

        sss.dependency 'CSkit/Base'
        sss.dependency 'CSkit/Cache'
        sss.dependency 'CSkit/Utility'

        sss.dependency 'CSkit/Text/Component'
        sss.dependency 'CSkit/Text/String'
        sss.dependency 'CSkit/Text/UseClass'

        sss.dependency 'CSkit/Model'
        sss.dependency 'CSkit/Model/Unicode'

        sss.dependency 'CSkit/Image'
        sss.dependency 'CSkit/Image/Categories'

        sss.dependency 'CSkit/Extended/Foundation'
        sss.dependency 'CSkit/Extended/Quartz'
        sss.dependency 'CSkit/Extended/UIKit'

        sss.dependency 'CSkit/CustomClass/CSBaseClass'

        sss.dependency 'CSkit/CustomClass/CSNetworkTools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

        sss.dependency 'CSkit/CustomClass/CSPopupController'
        sss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


        sss.dependency 'CSkit/CustomClass/CSIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


        sss.dependency 'CSkit/CustomClass/CSImageBrowser'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


        sss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

        sss.dependency 'CSkit/CustomClass/UITableViewProtocol'



        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSIndicator/*.{h,m}','CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSNotificationIndicator/*.{h,m}','CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSProgressIndicator/*.{h,m}','CSKit/CSKit/CSKit/CustomClass/CSIndicator/CSToastIndicator/*.{h,m}'

    end


    ss.subspec 'CSImageBrowser' do |sss|

        sss.dependency 'CSkit/Base'
        sss.dependency 'CSkit/Cache'
        sss.dependency 'CSkit/Utility'

        sss.dependency 'CSkit/Text/Component'
        sss.dependency 'CSkit/Text/String'
        sss.dependency 'CSkit/Text/UseClass'

        sss.dependency 'CSkit/Model'
        sss.dependency 'CSkit/Model/Unicode'

        sss.dependency 'CSkit/Image'
        sss.dependency 'CSkit/Image/Categories'

        sss.dependency 'CSkit/Extended/Foundation'
        sss.dependency 'CSkit/Extended/Quartz'
        sss.dependency 'CSkit/Extended/UIKit'

        sss.dependency 'CSkit/CustomClass/CSBaseClass'

        sss.dependency 'CSkit/CustomClass/CSNetworkTools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

        sss.dependency 'CSkit/CustomClass/CSPopupController'
        sss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


        sss.dependency 'CSkit/CustomClass/CSIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


        sss.dependency 'CSkit/CustomClass/CSImageBrowser'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


        sss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

        sss.dependency 'CSkit/CustomClass/UITableViewProtocol'



        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/*.{h,m}','CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Category/*.{h,m}','CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/Model/*.{h,m}','CSKit/CSKit/CSKit/CustomClass/CSImageBrowser/View/*.{h,m}'

    end



    ss.subspec 'CSPhotoGroupView' do |sss|

        sss.dependency 'CSkit/Base'
        sss.dependency 'CSkit/Cache'
        sss.dependency 'CSkit/Utility'

        sss.dependency 'CSkit/Text/Component'
        sss.dependency 'CSkit/Text/String'
        sss.dependency 'CSkit/Text/UseClass'

        sss.dependency 'CSkit/Model'
        sss.dependency 'CSkit/Model/Unicode'

        sss.dependency 'CSkit/Image'
        sss.dependency 'CSkit/Image/Categories'

        sss.dependency 'CSkit/Extended/Foundation'
        sss.dependency 'CSkit/Extended/Quartz'
        sss.dependency 'CSkit/Extended/UIKit'

        sss.dependency 'CSkit/CustomClass/CSBaseClass'

        sss.dependency 'CSkit/CustomClass/CSNetworkTools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

        sss.dependency 'CSkit/CustomClass/CSPopupController'
        sss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


        sss.dependency 'CSkit/CustomClass/CSIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


        sss.dependency 'CSkit/CustomClass/CSImageBrowser'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


        sss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

        sss.dependency 'CSkit/CustomClass/UITableViewProtocol'



        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/CSPhotoGroupView/*.{h,m}'

    end


    ss.subspec 'UITableViewProtocol' do |sss|

        sss.dependency 'CSkit/Base'
        sss.dependency 'CSkit/Cache'
        sss.dependency 'CSkit/Utility'

        sss.dependency 'CSkit/Text/Component'
        sss.dependency 'CSkit/Text/String'
        sss.dependency 'CSkit/Text/UseClass'

        sss.dependency 'CSkit/Model'
        sss.dependency 'CSkit/Model/Unicode'

        sss.dependency 'CSkit/Image'
        sss.dependency 'CSkit/Image/Categories'

        sss.dependency 'CSkit/Extended/Foundation'
        sss.dependency 'CSkit/Extended/Quartz'
        sss.dependency 'CSkit/Extended/UIKit'

        sss.dependency 'CSkit/CustomClass/CSBaseClass'

        sss.dependency 'CSkit/CustomClass/CSNetworkTools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Tools'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/Model'
        sss.dependency 'CSkit/CustomClass/CSNetworkTools/CSNetworkTopMaskView'

        sss.dependency 'CSkit/CustomClass/CSPopupController'
        sss.dependency 'CSkit/CustomClass/CSPopupController/Classes'


        sss.dependency 'CSkit/CustomClass/CSIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSNotificationIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSProgressIndicator'
        sss.dependency 'CSkit/CustomClass/CSIndicator/CSToastIndicator'


        sss.dependency 'CSkit/CustomClass/CSImageBrowser'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Category'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/Model'
        sss.dependency 'CSkit/CustomClass/CSImageBrowser/View'


        sss.dependency 'CSkit/CustomClass/CSPhotoGroupView'

        sss.dependency 'CSkit/CustomClass/UITableViewProtocol'



        sss.source_files = 'CSKit/CSKit/CSKit/CustomClass/UITableViewProtocol/*.{h,m}'

    end






end






end
