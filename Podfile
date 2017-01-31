# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Champy' do
  pod 'Socket.IO-Client-Swift', '~> 8.0.2' # swift 3
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
  #pod 'FacebookCore'
  #pod 'FacebookLogin'
  #pod 'FacebookShare'
end

target 'ChampyUITests' do
  pod 'Socket.IO-Client-Swift', '~> 8.0.2' # swift 3
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

target 'ChampyTests' do
  pod 'Socket.IO-Client-Swift', '~> 8.0.2'
  pod 'Alamofire', '~> 4.0'
  pod 'SwiftyJSON'
  pod 'SwiftHTTP', '~> 2.0.0'
  pod 'AsyncSwift'
  pod 'JSONWebToken'
  pod 'Kingfisher', '~> 3.0'
  pod 'Fusuma', :git => 'https://github.com/pruthvikar/Fusuma.git', :commit => '503865a'
  pod 'Device', '~> 2.0.0'
  
 end

target 'ChampyTestsSwift3.0' do
  pod 'Socket.IO-Client-Swift', '~> 8.0.2' # swift 3
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

target 'ChampyUITests3.0' do
  pod 'Socket.IO-Client-Swift', '~> 8.0.2' # swift 3
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


