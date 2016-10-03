# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'ChampySwift' do
  pod 'Fusuma'
  pod 'Socket.IO-Client-Swift', '~> 8.0.2'
  pod 'PresenterKit', :git => 'https://github.com/jessesquires/PresenterKit.git', :branch => 'develop'
  pod 'Alamofire', '~> 4.0'
  pod 'JSONWebToken'
  pod 'SwiftyJSON'
  pod 'SwiftHTTP', '~> 2.0.0'
  pod 'AsyncSwift'
  pod 'Kingfisher', '~> 2.0'
  
end

target 'ChampySwiftUITests' do
  pod 'Fusuma'
  pod 'Socket.IO-Client-Swift', '~> 8.0.2'
  pod 'PresenterKit', :git => 'https://github.com/jessesquires/PresenterKit.git', :branch => 'develop'
  pod 'Alamofire', '~> 4.0'
  pod 'JSONWebToken'
  pod 'SwiftyJSON'
  pod 'SwiftHTTP', '~> 2.0.0'
  pod 'AsyncSwift'
  pod 'Kingfisher', '~> 2.0'
  
end

target 'ChampySwiftTests' do
  pod 'Fusuma'
  pod 'Socket.IO-Client-Swift', '~> 8.0.2'
  pod 'PresenterKit', :git => 'https://github.com/jessesquires/PresenterKit.git', :branch => 'develop'
  pod 'Alamofire', '~> 4.0'
  pod 'JSONWebToken'
  pod 'SwiftyJSON'
  pod 'SwiftHTTP', '~> 2.0.0'
  pod 'AsyncSwift'
  pod 'Kingfisher', '~> 2.0'
  
 end



post_install do |installer|
  installer.pods_project.targets.each do
    |target| target.build_configurations.each do
      |config| config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "2.3"
    end
  end
end


