# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'







target 'pomodoro_last' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
   
   
  
   
  # Pods for Pomodoro
  pod 'Firebase/Analytics'
  pod 'Firebase/Firestore',:modular_headers => true
  pod 'KCCircularTimer'
  pod 'Charts'

post_install do |installer|
  system("mkdir -p Pods/Headers/Public/FirebaseCore && cp Pods/FirebaseCore/Firebase/Core/Public/* Pods/Headers/Public/FirebaseCore/")
  #installer.generated_projects.each do |project|
    #project.targets.each do |target|
      #target.build_configurations.each do |config|
        #config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        #config.build_settings['ENABLE_BITCODE'] = 'NO'
        #config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      #end
    #end
  #end
end

end


