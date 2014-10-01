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
  s.version          = "0.2"
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

      s.subspec 'NSObject' do |sub|
        sub.source_files = 'SHLib/Categories/NSObject/*'
      end

      s.subspec 'NSString' do |sub|
        sub.source_files = 'SHLib/Categories/NSString/*'
      end

      s.subspec 'UIColor' do |sub|
        sub.source_files = 'SHLib/Categories/UIColor/*'
      end

      s.subspec 'UIImage' do |sub|
        sub.source_files = 'SHLib/Categories/UIImage/*'
      end

      s.subspec 'UIImageView' do |sub|
        sub.source_files = 'SHLib/Categories/UIImageView/*'
      end

      s.subspec 'UIView' do |sub|
        sub.source_files = 'SHLib/Categories/UIView/*'
      end

      s.subspec 'Container' do |sub|
        sub.source_files = 'SHLib/Categories/Container/*/*'
      end

      s.subspec 'SHTableViewDelegate' do |sub|
        sub.source_files = 'SHLib/Classes/SHTableViewDelegate/*', 'SHLib/Categories/NSObject/*'
      end

end
