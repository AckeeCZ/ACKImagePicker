Pod::Spec.new do |s|
    s.name             = 'ACKImagePicker'
    s.version          = '0.1'
    s.summary          = 'Simplify image picking'
    s.description      = <<-DESC
    ACKImagePicker creates a system-like image picker experience.
    DESC
    s.homepage         = 'https://github.com/LukasHromadnik/ACKImagePicker'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Lukáš Hromadník' => 'lukas.hromadnik@gmail.com' }
    s.social_media_url = "https://twitter.com/lukashromadnik"
    s.source           = { :git => 'https://github.com/LukasHromadnik/ACKImagePicker.git', :tag => s.version.to_s }
    s.ios.deployment_target = '9.0'
    s.source_files     = 'ACKImagePicker/*.swift'
    s.swift_version    = '5.0'
end
