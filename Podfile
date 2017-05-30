# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

def pods
  pod  'SwiftRandom'
  pod 'SideMenu'
  pod 'Socket.IO-Client-Swift' # swift 3
  pod 'Alamofire', '~> 4.0' # swift 3
  pod 'SwiftyJSON' # swift 3
  pod 'SwiftHTTP', '~> 2.0.0' # swift 3
  pod 'AsyncSwift' # swift 3
  pod 'JSONWebToken' # swift 3
  pod 'Kingfisher', '~> 3.0' # swift 3
  pod 'Fusuma', :git => 'https://github.com/pruthvikar/Fusuma.git', :commit => '503865a'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Device', '~> 2.0.0'
end

target 'Champy' do
  pods
end

target 'ChampyUITests' do
  pods
  
end

target 'ChampyTests' do
  pods
  
end

target 'ChampyTestsSwift3.0' do
  pods
  
end

target 'ChampyUITests3.0' do
  pods
  
  
end

post_install do |installer|
  installer.pods_project.targets.each do
    |target| target.build_configurations.each do
      |config| config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |configuration|
#      configuration.build_settings['SWIFT_VERSION'] = "3.0"
#    end
#  end
#end


