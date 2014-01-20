Pod::Spec.new do |s|
  s.name         =  'ImageBrowser'
  s.version      =  '0.2'
  s.license      =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary      =  'A simple picture viewer.'
  s.homepage     =  'https://github.com/kikohz/ImageBrowser'
  s.author       =  { 'H_z' => 'kikohz@gmail.com' }
  s.source       =  { :git => 'https://github.com/kikohz/ImageBrowser.git', :tag => '0.2' }
  s.platform     =  :ios
  s.source_files =  'Source'
  s.requires_arc =  true
end
