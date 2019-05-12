Pod::Spec.new do |s|
  s.name = "Wormer"
  s.version = "2.2.0"
  s.license = 'MIT'
  s.summary = "Simple dependency injection container in pure Swift"
  s.homepage     = "https://github.com/jeden/wormer"
  s.authors = { "Antonio Bello" => "jeden@elapsus.com" }
  s.social_media_url   = "http://twitter.com/ant_bello"
  s.source = { :git => "https://github.com/jeden/wormer.git", :tag => '2.2.0' }
  s.swift_version = "5.0"

  s.requires_arc = true
  s.ios.deployment_target = "9.0"
  #s.osx.deployment_target = "10.9"
  #s.watchos.deployment_target = "2.0"
  #s.tvos.deployment_target = "9.0"

  s.source_files  = "source/**/*.swift"
end
