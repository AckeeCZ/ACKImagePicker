Pod::Spec.new do |s|
    s.name             = 'ACKImagePicker'
    s.version          = '0.4.0'
    s.summary          = 'Simplify image picking'
    s.description      = <<-DESC
    ACKImagePicker creates a system-like image picker experience.
    DESC
    s.homepage         = 'https://github.com/AckeeCZ/ACKImagePicker'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Ackee' => 'info@ackee.cz' }
    s.social_media_url = "https://twitter.com/AckeeCZ"
    s.source           = { :git => 'https://github.com/AckeeCZ/ACKImagePicker.git', :tag => s.version.to_s }
    s.ios.deployment_target = '9.0'
    s.source_files     = 'ACKImagePicker/*.swift'
    s.swift_version    = '5.0'
    s.resource_bundle = { "ACKImagePicker" => ["ACKImagePicker/Supporting files/*.lproj/*.strings"] }
end
