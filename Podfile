# Uncomment the next line to define a global platform for your project
  platform :ios, '16.0'

target 'Time Tracker' do

  # Comment the next line if you don't want to use dynamic frameworks

  use_frameworks!
  pod 'FirebaseFirestoreSwift'
  pod 'FirebaseFirestore'
  pod 'FirebaseAuth'
  # Pods for Time Tracker

end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  end
 end
end
