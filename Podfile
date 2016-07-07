# Uncomment this line to define a global platform for your project
platform :ios, '8.4'
# Uncomment this line if you're using Swift
use_frameworks!

target 'ChampySwift' do
  pod 'Fusuma'
  pod 'Socket.IO-Client-Swift', '~> 3.1.4'
  pod 'PresenterKit', :git => 'https://github.com/jessesquires/PresenterKit.git', :branch => 'develop'
  pod 'Alamofire', '~> 2.0'
  pod 'Socket.IO-Client-Swift', '~> 3.1.4'
  pod 'JSONWebToken'
  pod 'SwiftyJSON'
  pod 'SwiftHTTP'
  pod 'AsyncSwift'
  pod 'Parse'
  pod 'Kingfisher', '~> 2.0'
  pod 'ALCameraViewController'
  pod 'DynamicBlurView'
  pod 'SwipyCell', '~> 1.0.0'
end

target 'ChampySwiftTests' do
  pod 'PresenterKit', :git => 'https://github.com/jessesquires/PresenterKit.git', :branch => 'develop'
  pod 'Alamofire', '~> 2.0'
  pod 'Socket.IO-Client-Swift', '~> 3.1.4'
  pod 'JSONWebToken'
  pod 'SwiftyJSON'
  pod 'SwiftHTTP'
  pod 'AsyncSwift'
 pod 'Kingfisher', '~> 2.0'
  pod 'ALCameraViewController'
  pod 'DynamicBlurView'
end

target 'ChampySwiftUITests' do
  
end

post_install do |installer|
  installer.pods_project.targets.each do
    |target| target.build_configurations.each do
      |config| config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end


