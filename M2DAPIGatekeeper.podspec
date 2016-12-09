#
# Be sure to run `pod lib lint M2DAPIGatekeeper.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "M2DAPIGatekeeper"
  s.version          = "2.0.4"
  s.summary          = "Simple API networking framework."
  s.description      = <<-DESC
							Simple API networking framework.
							Easy to send request for Web API.
                       DESC
  s.homepage         = "https://github.com/0x0c/M2DAPIGatekeeper"
  s.license          = 'MIT'
  s.author           = { "Akira Matsuda" => "akira.m.itachi@gmail.com" }
  s.source           = { :git => "https://github.com/0x0c/M2DAPIGatekeeper.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'

  s.public_header_files = 'Pod/Classes/M2DAPIGatekeeper/*.h', 'Pod/Classes/M2DAPIRequest/*.h'
  s.frameworks = 'UIKit', 'QuartzCore'
end
