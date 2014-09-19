#
# Be sure to run `pod lib lint SHLib.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SHLib"
  s.version          = "0.1.0"
  s.summary          = "A series of useful functions used often in projects."
  s.description      = <<-DESC
                       Some useful functions and categories I found myself using for most of my projects.
                       DESC
  s.homepage         = "https://github.com/StratusHunter/SHLib"
  s.license          = 'MIT'
  s.author           = { "Terence Baker" => "stratushunter@gmail.com" }
  s.source           = { :git => "https://github.com/StratusHunter/SHLib.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'SHLib/*/*/*'
  s.framework  = 'UIKit'
end
