source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

use_frameworks!

target "XTrip" do
    
pod 'XCGLogger', '~> 6.1.0'

pod 'FacebookCore', '~> 0.5.0'
pod 'FacebookLogin', '~> 0.5.0'
pod 'FacebookShare', '~> 0.5.0'
pod 'FBSDKCoreKit', '~> 4.37'
pod 'FBSDKLoginKit', '~> 4.37'
pod 'FBSDKShareKit', '~> 4.37'

pod 'IQKeyboardManagerSwift', '~> 6.0.4'

pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'

pod 'NVActivityIndicatorView', '~> 4.4.0'

pod 'Alamofire', '~> 4.4'
pod 'ObjectMapper', '3.3.0'
pod 'OHHTTPStubs/Swift'
pod 'SwiftDate', '~> 5.0.4'
pod 'SideMenu'
pod 'KeychainAccess'
pod 'SnapKit', '4.2.0'
pod 'Skeleton'
pod 'GooglePlaces'
pod 'Firebase/Core'
pod 'FirebaseMessaging'
pod 'ESTabBarController-swift'
pod 'pop', '~> 1.0'
pod 'Kingfisher'
pod 'DZNEmptyDataSet'
pod 'KMNavigationBarTransition'
pod 'DateToolsSwift'
pod 'RealmSwift', '~> 2.10.1'
pod 'MJRefresh'
pod 'Firebase/DynamicLinks'
pod 'PhoneNumberKit', '~> 2.5'

pod 'UINavigationItem+Margin'
pod 'MXSegmentedPager', :git => 'https://github.com/maxep/MXSegmentedPager.git', :tag => '3.2.0'
pod 'GoogleMaps'
pod 'SimpleImageViewer', '~> 1.1.1'
pod 'Fabric'
pod 'Crashlytics'

end

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['SWIFT_VERSION'] = '4.2'
end
end
end
