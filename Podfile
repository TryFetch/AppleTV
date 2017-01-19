source 'https://github.com/CocoaPods/Specs.git'
platform :tvos, '9.0'
use_frameworks!

def shared
  pod 'Alamofire', '~> 3.5'
  pod 'AlamofireImage', '~> 2.5'
  pod 'SwiftyJSON', '~> 2.4'
  pod 'KeychainAccess', '~> 2.4'
  pod 'Realm'
  pod 'RealmSwift'
  pod 'Downpour', '~> 0.1.0'
end

target 'PutioKit' do
  shared
end

target 'FetchTV' do
  shared
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end