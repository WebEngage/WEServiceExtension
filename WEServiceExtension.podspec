
Pod::Spec.new do |s|
  s.name             = 'WEServiceExtension'
  s.version          = '0.1.0'
  s.summary          = 'Extension Target SDK for adding WebEngage Rich Push Notifications support'

  spec.description      = <<-DESC
   This pod includes various subspecs which are intended for use in Application Extensions, and depends on APIs which are App Extension Safe. The Core subspecs provides APIs which lets you track Users and Events from within Application Extensions.
   DESC

  spec.homepage           = 'https://webengage.com'
  spec.documentation_url  = 'https://docs.webengage.com/docs/ios-getting-started'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'BhaveshWebEngage' => 'bhavesh.sarwar@webengage.com' }
  s.source           = { :git => 'https://github.com/BhaveshWebEngage/WEServiceExtension.git', :tag => s.version.to_s }
  spec.platform           = :ios
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '10.0'
<<<<<<< Updated upstream
  s.source_files = 'Sources/WEServiceExtension/**/*'
  
  # s.resource_bundles = {
  #   'WEServiceExtension' => ['WEServiceExtension/Assets/*.png']
  # }
=======
  s.source_files = 'WEServiceExtension/Sources/WEServiceExtension/**/*'
>>>>>>> Stashed changes

end
