Pod::Spec.new do |s|
  s.name = 'Aeon'
  s.version = '0.2.1'
  s.license = 'MIT'
  s.summary = 'GCD based HTTP server for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/Aeon'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/Aeon.git', :tag => 'v0.2.1' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Aeon/**/*.swift',
                   'HTTPServerType/**/*.swift'

  s.dependency 'Currents', '0.2'
  s.dependency 'Kalopsia', '0.2'
  s.dependency 'Luminescence', '0.3'
  s.dependency 'Curvature', '0.1'
  s.dependency 'Otherside', '0.1'

  s.requires_arc = true
end