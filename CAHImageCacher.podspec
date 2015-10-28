#
# Be sure to run `pod lib lint CAHImageCacher.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CAHImageCacher"
  s.version          = "0.1.0"
  s.summary          = "Mostly full-featured, asynchronous image cacher with a simple interface."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Mostly full-featured, asynchronous image cacher with a simple interface. CAHImageCacher asynchronously downloads an image from a URL, caches it to a dictionary, renders it to a UIImageView, and saves it to disk.
                       DESC

  s.homepage         = "https://github.com/chaseholland/CAHImageCacher"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Chase Holland" => "lurch09@gmail.com" }
  s.source           = { :git => "https://github.com/chaseholland/CAHImageCacher.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CAHImageCacher' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
