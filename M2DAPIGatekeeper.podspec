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
  s.version          = "0.1.0"
  s.summary          = "A short description of M2DAPIGatekeeper."
  s.description      = <<-DESC
                       An optional longer description of M2DAPIGatekeeper

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/0x0c/M2DAPIGatekeeper"
  s.license          = 'MIT'
  s.author           = { "Akira Matsuda" => "akira.m.itachi@gmail.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/M2DAPIGatekeeper.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
