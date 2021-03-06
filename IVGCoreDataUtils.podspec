Pod::Spec.new do |s|
  s.name         = "IVGCoreDataUtils"
  s.version      = "1.0.4"
  s.summary      = "Miscellaneous core data helper routines for iOS"
  s.homepage     = "https://github.com/ivygulch/IVGCoreDataUtils"
  s.license      = { :type => 'MIT', :file => 'LICENSE'}
  s.author       = { "dwsjoquist" => "dwsjoquist@sunetos.com"}
  s.source       = { :git => "https://github.com/ivygulch/IVGCoreDataUtils.git", :tag => "v1.0.4" }
  s.platform     = :ios, '7.0'
  s.source_files = 'LibClasses/*{.h,.m}'
  s.frameworks   = 'Foundation','UIKit','CoreData','CoreGraphics','CoreData'
  s.requires_arc = true
  s.dependency 'IVGUtils'
end
