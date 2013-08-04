Pod::Spec.new do |s|
    s.name         = "ObjectiveHAL"
    s.version      = "0.1.0"
    s.summary      = "Objective-C implementation of the JSON Hypertext Application Language."
    s.homepage     = "https://github.com/ObjectiveHAL/ObjectiveHAL"
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.author       = { "Bennett Smith" => "bennett@focalshift.com" }
    s.source       = { :git => "https://github.com/ObjectiveHAL/ObjectiveHAL.git", :tag => "0.1.0" }
    s.ios.deployment_target = '6.0'
    s.osx.deployment_target = '10.7'
    s.source_files = 'ObjectiveHAL', 'ObjectiveHAL/**/*.{h,m}'
    s.public_header_files = 'ObjectiveHAL/ObjectiveHAL.h'
    s.requires_arc = true
end
