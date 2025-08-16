Pod::Spec.new do |spec|
  # Metadata
  spec.name         = "SwiftIntelligence"
  spec.version      = "1.0.0"
  spec.summary      = "Advanced AI/ML Framework for Apple Platforms"
  spec.description  = <<-DESC
    SwiftIntelligence is a comprehensive AI/ML framework designed specifically for Apple platforms.
    It provides powerful, privacy-focused artificial intelligence capabilities including:
    - Natural Language Processing (NLP)
    - Computer Vision
    - Speech Recognition and Synthesis
    - Machine Learning
    - Privacy-preserving AI
    - Multi-platform support (iOS, macOS, watchOS, tvOS, visionOS)
  DESC
  
  spec.homepage     = "https://github.com/username/SwiftIntelligence"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "SwiftIntelligence Team" => "team@swiftintelligence.com" }
  spec.source       = { :git => "https://github.com/username/SwiftIntelligence.git", :tag => "v#{spec.version}" }
  
  # Platform Support
  spec.ios.deployment_target     = "17.0"
  spec.osx.deployment_target     = "14.0"
  spec.watchos.deployment_target = "10.0"
  spec.tvos.deployment_target    = "17.0"
  # Note: visionOS not yet supported by CocoaPods
  
  # Swift Version
  spec.swift_version = "5.9"
  
  # Source Files
  spec.source_files = "Sources/**/*.{swift,h,m}"
  spec.exclude_files = [
    "Sources/**/Tests/**/*",
    "Sources/**/Examples/**/*"
  ]
  
  # Resources
  spec.resource_bundles = {
    "SwiftIntelligence" => [
      "Sources/SwiftIntelligenceCore/Resources/**/*.{strings,xcassets,json,plist}",
      "Sources/SwiftIntelligence/PrivacyInfo.xcprivacy"
    ]
  }
  
  # Subspecs for modular installation
  
  # Core Module (Required)
  spec.subspec 'Core' do |core|
    core.source_files = "Sources/SwiftIntelligenceCore/**/*.swift"
    core.resource_bundles = {
      "SwiftIntelligenceCore" => [
        "Sources/SwiftIntelligenceCore/Resources/**/*.{strings,lproj}"
      ]
    }
  end
  
  # NLP Module
  spec.subspec 'NLP' do |nlp|
    nlp.dependency 'SwiftIntelligence/Core'
    nlp.dependency 'SwiftIntelligence/ML'
    nlp.source_files = "Sources/SwiftIntelligenceNLP/**/*.swift"
    nlp.frameworks = "NaturalLanguage"
  end
  
  # Vision Module
  spec.subspec 'Vision' do |vision|
    vision.dependency 'SwiftIntelligence/Core'
    vision.dependency 'SwiftIntelligence/ML'
    vision.source_files = "Sources/SwiftIntelligenceVision/**/*.swift"
    vision.frameworks = "Vision", "CoreImage", "CoreML"
  end
  
  # Speech Module
  spec.subspec 'Speech' do |speech|
    speech.dependency 'SwiftIntelligence/Core'
    speech.dependency 'SwiftIntelligence/NLP'
    speech.source_files = "Sources/SwiftIntelligenceSpeech/**/*.swift"
    speech.frameworks = "Speech", "AVFoundation"
  end
  
  # ML Module
  spec.subspec 'ML' do |ml|
    ml.dependency 'SwiftIntelligence/Core'
    ml.source_files = "Sources/SwiftIntelligenceML/**/*.swift"
    ml.frameworks = "CoreML", "CreateML"
  end
  
  # Privacy Module
  spec.subspec 'Privacy' do |privacy|
    privacy.dependency 'SwiftIntelligence/Core'
    privacy.source_files = "Sources/SwiftIntelligencePrivacy/**/*.swift"
    privacy.frameworks = "CryptoKit", "Security"
  end
  
  # Reasoning Module
  spec.subspec 'Reasoning' do |reasoning|
    reasoning.dependency 'SwiftIntelligence/Core'
    reasoning.dependency 'SwiftIntelligence/ML'
    reasoning.source_files = "Sources/SwiftIntelligenceReasoning/**/*.swift"
  end
  
  # Image Generation Module
  spec.subspec 'ImageGeneration' do |imagegen|
    imagegen.dependency 'SwiftIntelligence/Core'
    imagegen.dependency 'SwiftIntelligence/Vision'
    imagegen.source_files = "Sources/SwiftIntelligenceImageGeneration/**/*.swift"
    imagegen.frameworks = "CoreGraphics", "CoreImage"
  end
  
  # Network Module
  spec.subspec 'Network' do |network|
    network.dependency 'SwiftIntelligence/Core'
    network.source_files = "Sources/SwiftIntelligenceNetwork/**/*.swift"
    network.frameworks = "Network"
  end
  
  # Cache Module
  spec.subspec 'Cache' do |cache|
    cache.dependency 'SwiftIntelligence/Core'
    cache.source_files = "Sources/SwiftIntelligenceCache/**/*.swift"
  end
  
  # Metrics Module
  spec.subspec 'Metrics' do |metrics|
    metrics.dependency 'SwiftIntelligence/Core'
    metrics.source_files = "Sources/SwiftIntelligenceMetrics/**/*.swift"
  end
  
  # Benchmarks Module
  spec.subspec 'Benchmarks' do |benchmarks|
    benchmarks.dependency 'SwiftIntelligence/Core'
    benchmarks.source_files = "Sources/SwiftIntelligenceBenchmarks/**/*.swift"
  end
  
  # Frameworks
  spec.frameworks = [
    "Foundation",
    "Combine",
    "SwiftUI",
    "UIKit",
    "CoreML",
    "Vision",
    "NaturalLanguage",
    "Speech",
    "AVFoundation",
    "CoreImage",
    "CoreGraphics",
    "Security",
    "CryptoKit"
  ]
  
  # Compiler Flags
  spec.pod_target_xcconfig = {
    'SWIFT_VERSION' => '5.9',
    'SWIFT_STRICT_CONCURRENCY' => 'complete',
    'SWIFT_UPCOMING_FEATURE_BARE_SLASH_REGEX_LITERALS' => 'YES',
    'OTHER_SWIFT_FLAGS' => '-enable-experimental-feature StrictConcurrency',
    'ENABLE_BITCODE' => 'NO',
    'ENABLE_TESTABILITY' => 'YES',
    'GENERATE_INFOPLIST_FILE' => 'YES',
    'IPHONEOS_DEPLOYMENT_TARGET' => '17.0',
    'MACOSX_DEPLOYMENT_TARGET' => '14.0',
    'WATCHOS_DEPLOYMENT_TARGET' => '10.0',
    'TVOS_DEPLOYMENT_TARGET' => '17.0'
  }
  
  # User Target XCConfig
  spec.user_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited)',
    'OTHER_LDFLAGS' => '$(inherited) -framework "SwiftIntelligence"'
  }
  
  # Documentation
  spec.documentation_url = "https://github.com/username/SwiftIntelligence/wiki"
  
  # Social Media
  spec.social_media_url = "https://twitter.com/swiftintelligence"
  
  # Screenshots (for CocoaPods website)
  spec.screenshots = [
    "https://raw.githubusercontent.com/username/SwiftIntelligence/main/Resources/screenshot1.png",
    "https://raw.githubusercontent.com/username/SwiftIntelligence/main/Resources/screenshot2.png"
  ]
  
  # Requires ARC
  spec.requires_arc = true
  
  # Module Map
  spec.module_name = 'SwiftIntelligence'
  
  # Test Specs
  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'
    test_spec.frameworks = 'XCTest'
  end
end