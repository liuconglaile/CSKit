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

end
