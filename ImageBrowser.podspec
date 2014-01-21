Pod::Spec.new do |s|

  s.name         = "ImageBrowser"
  s.version      = "0.2.1"
  s.summary      = "A simple picture viewer."

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "kikohz" => "kikohz@gmail.com" }
  s.homepage     = "https://github.com/kikohz/ImageBrowser"
  s.platform     = :ios, '5.0'

  #  When using multiple platforms
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'

  s.source       = { :git => "https://github.com/kikohz/ImageBrowser.git", :tag => "v0.2.1" }
  s.source_files  = 'Source', 'Source/**/*.{h,m}'

  s.resources = "Source/Resources/*.png"

  # s.frameworks = 'SomeFramework', 'AnotherFramework'

  s.requires_arc = true

  s.dependency 'SDWebImage',  '~> 3.5.1'

end
