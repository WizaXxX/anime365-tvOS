post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end


target 'anime365-tvOS' do
  use_frameworks!
  
  pod 'SwiftKeychainWrapper'
  pod 'Alamofire'
  pod 'RealmSwift', '~>10'
  pod 'SwiftSoup'
  pod 'ParallaxView'
  pod 'FirebaseFirestore'
  pod 'FirebaseFirestoreSwift'
end

target 'TopShelf' do
  use_frameworks!
  
  pod 'SwiftKeychainWrapper'
  pod 'Alamofire'
  pod 'SwiftSoup'
  pod 'FirebaseFirestore'
  pod 'FirebaseFirestoreSwift'
end
