#
# Be sure to run `pod lib lint hellosdk_source.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'hellosdk_source'
  s.version          = '0.1.0'
  s.summary          = 'hellosdk framework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/eye1234456/MyTestLibs'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'eye' => 'eye@gmail.com' }
  s.source           = { :git => 'https://github.com/eye1234456/MyTestLibs.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files  =  "HelloSDK/HelloSDK/**/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"

  s.resource = [
    'HelloSDK/HelloSDK/Resource/*{xcassets}',
    'HelloSDK/HelloSDK/**/*.{bundle}',
    'HelloSDK/HelloSDK/**/*{xib,storyboard}'
  ]

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  s.vendored_frameworks = [
  # 'Resource/hellosdk/thirdLib/abc.xcframework',
  ]

  
  # s.resource_bundles = {
  #   'hellosdk' => ['hellosdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'MyLayout'
  s.dependency 'ReactiveObjC'
  s.dependency 'AFNetworking'
  s.dependency 'SDWebImage'
  s.dependency 'Masonry'

  s.requires_arc = true
  s.static_framework = false
end
