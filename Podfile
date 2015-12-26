# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'
# pod trunk push Theater.podspec --allow-warnings 

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

def crashlytics
    pod 'Fabric'
    pod 'Crashlytics'
end

def theater
    pod 'Theater' , :git => "https://github.com/darioalessandro/Theater.git"
end

def testing_pods
    pod 'Quick', '~> 0.8.0'
    pod 'Nimble', '3.0.0'
end

target 'Beacon' do
    theater
    crashlytics
end

target 'Receiver' do
    theater
    crashlytics
end

