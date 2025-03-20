#
# Be sure to run `pod lib lint TronWalletWeb3Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TronWalletWeb3Swift'
  s.version          = '1.0.1'
  s.summary          = 'TronWalletWeb3Swift is an iOS toolbelt for interaction with the Tron network.'

  s.homepage         = 'https://github.com/TronLink/TronWalletWeb3Swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'tronlinkdev'
  s.source           = { :git => 'https://github.com/TronLink/TronWalletWeb3Swift.git', :tag => s.version.to_s }
  s.platform = :ios, '13.0'

  s.source_files = 'TronWalletWeb3Swift/Classes/**/*'
  
  s.swift_version = '4.2'
  s.module_name = 'web3swift'
  s.dependency 'PromiseKit', '~> 6.4'
  s.dependency 'BigInt', '~> 3.1'
  s.dependency 'secp256k1.c', '~> 0.1'
  s.dependency 'keccak.c', '~> 0.1'
  s.dependency 'scrypt.c', '~> 0.1'
end
