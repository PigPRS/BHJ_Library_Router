#
# Be sure to run `pod lib lint BHJ_Library_Router.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BHJ_Library_Router'
  s.version          = '0.1.5'
  s.summary          = '路由库'
  s.description      = <<-DESC
路由库
路由库
路由库
                       DESC

  s.homepage         = 'https://code.aliyun.com/BHJ_iOS/BHJ_Library_Router'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '26230197' => '26230197@qq.com' }
  s.source           = { :git => 'https://code.aliyun.com/BHJ_iOS/BHJ_Library_Router.git', :tag => s.version.to_s }

  s.platform     = :ios, "10.0"
  s.swift_version  = "5.0"

  s.source_files = 'BHJ_Library_Router/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BHJ_Library_Router' => ['BHJ_Library_Router/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
