
Pod::Spec.new do |s|
    s.name             = 'WEServiceExtension'
    s.version          = '1.1.0'
    s.summary          = 'Extension Target SDK for adding WebEngage Rich Push Notifications support'
    
    s.description      = <<-DESC
    This pod includes various subspecs which are intended for use in Application Extensions, and depends on APIs which are App Extension Safe. The Core subspecs provides APIs which lets you track Users and Events from within Application Extensions.
    DESC
    
    s.homepage           = 'https://webengage.com'
    s.documentation_url  = 'https://docs.webengage.com/docs/ios-getting-started'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'WebEngage' => 'mobile@webengage.com' }
    s.source           = { :git => 'https://github.com/WebEngage/WEServiceExtension.git', :tag => s.version.to_s }
    s.platform           = :ios
    s.ios.deployment_target = '12.0'
    s.swift_version = '5.0'
    s.source_files = 'Sources/WEServiceExtension/**/*'
    s.weak_frameworks      = 'UserNotifications'
    s.dependency 'WebEngage','>= 6.4.0'
    
end
