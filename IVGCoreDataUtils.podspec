Pod::Spec.new do |s|
  s.name         = "IVGCoreDataUtils"
  s.version      = "0.0.1"
  s.summary      = "Miscellaneous core data helper routines for iOS"
  s.homepage     = "http://github.com/ivygulch/IVGCoreDataUtils"
  s.license      = { :type => 'MIT', :file => 'LICENSE'}
  s.author       = { "dwsjoquist" => "dwsjoquist@sunetos.com"}
  s.source       = { :git => "git@github.com:ivygulch/IVGCoreDataUtils.git" }
  s.platform     = :ios, '5.0'
  s.source_files = 'LibClasses/*{.h,.m}'
  s.frameworks   = 'Foundation','UIKit','CoreData','CoreGraphics','CoreData'
  s.requires_arc = true
end
