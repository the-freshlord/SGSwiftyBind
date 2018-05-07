Pod::Spec.new do |s|
  s.name                  = "SGSwiftyBind"
  s.version               = "1.0.1"
  s.summary               = "A light weight approach to event based programming"
  s.homepage              = "https://github.com/eman6576/SGSwiftyBind"
  s.license               = { :type => "MIT" }
  s.author                = { "Manny Guerrero" => "emanuelguerrerodev@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.11"
  s.source                = { :git => "https://github.com/eman6576/SGSwiftyBind.git", :tag => s.version }
  s.source_files          = "Sources/SGSwiftyBind/*.swift", 
  s.exclude_files         = "Classes/Exclude"
end