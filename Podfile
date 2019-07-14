# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'KMC-Player' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'PlayKit'
  pod 'PlayKitProviders'
  pod 'KalturaClient'

  target 'KMC-PlayerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'KMC-PlayerUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

pre_install do |installer|
    def installer.verify_no_static_framework_transitive_dependencies; end
end

post_install do |installer| 
    installer.pods_project.targets.each do |target| 
        target.build_configurations.each do |config| 
            config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
        end 
    end 
end
