#
# Be sure to run `pod lib lint CDShare.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CDShare'
  s.version          = '0.1.2'
  s.summary          = 'CDShare, is a framework for sharing CoreData between applications in IOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  `CDShare` will answer the question: <br> How do we share CoreData between `2*n` application, where n >= 1?
                       DESC

  s.homepage         = 'https://github.com/vadeara/CDShare'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vodaion' => 'vanea.voda@gmail.com' }
  s.social_media_url = "http://twitter.com/vodaion"
  s.source           = { :git => 'https://github.com/vadeara/CDShare.git', :tag => s.version.to_s }
  s.swift_version = '4.2'
  s.ios.deployment_target = '11.0'

  s.source_files = 'CDShare/CDShare/Classes/**/*'
  
end
