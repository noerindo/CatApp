# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'


source 'https://github.com/CocoaPods/Specs.git'

def network
  pod 'Alamofire', '~> 5.8'
end

def rx
  pod 'RxSwift', '6.5.0'
  pod 'RxCocoa', '6.5.0'
  pod 'RxDataSources'
  pod 'Action'
end


target 'CatApp' do
  platform :ios, '13.0'
  use_frameworks!
  network
  rx
  pod 'SnapKit', '~> 5.0.0'
  pod 'RealmSwift', '~>10'
  pod 'SnackBar.swift'
  pod 'Kingfisher', '~> 7.0'
  pod 'SideMenu'
  pod 'SkeletonView'
  pod 'i18next'
  
  
  
  target 'CatAppTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'CatAppUITests' do
    # Pods for testing
  end
  
end

