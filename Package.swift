// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IOSBaseKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "IOSBaseKit",
            targets: ["IOSBaseKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/yannickl/DynamicColor.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.5.3")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "12.1.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.5.0")),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", .upToNextMajor(from: "12.9.0")),
        .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform", .upToNextMajor(from: "3.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IOSBaseKit",
            dependencies: [
                "Alamofire",
                "DynamicColor",
                "Factory",
                "Kingfisher",
                .product(name: "GoogleUserMessagingPlatform", package: "swift-package-manager-google-user-messaging-platform"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseInstallations", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
            ]
        ),
    ]
)
