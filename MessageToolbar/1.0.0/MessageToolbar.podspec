Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "MessageToolbar"
s.summary = "MessageToolbar is an elegant drop-in message toolbar for your chat modules."
s.requires_arc = true
s.version = "1.0.0"
s.license = { :type => "MIT", :file => "LICENSE" }
s.author = { "Tarek Sabry" => "tareksabry444@outlook.com" }
s.homepage = "https://github.com/tareksabry1337/MessageToolbar"
s.source = { :git => "https://github.com/tareksabry1337/MessageToolbar.git",
:tag => "#{s.version}" }
s.framework = "UIKit"
s.framework = "AudioToolbox"
s.framework = "AVFoundation"
s.dependency 'Shimmer', '~> 1.0.2'
s.source_files = "MessageToolbar/**/*.swift"
s.swift_version = "4.2"
s.resource_bundles = {
    'MessageToolbar' => ['MessageToolbar/Assets.xcassets']
}

end
