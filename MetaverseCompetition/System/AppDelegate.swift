//
//  AppDelegate.swift
//  CoreML+ARKit+Reformatting
//
//  Created by HayeonKim on 2022/07/28.
//

import SwiftUI
import ARKit

@main
struct CoreMLApp: App {
    @discardableResult
    func checkIfARKitAvailable() -> Bool {
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
//            return
        }

        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) else {
            fatalError("""
                Scene reconstruction requires a device with a LiDAR Scanner, such as the 4th-Gen iPad Pro.
            """)
        }
        return true
    }
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    // TODO: - Need to add Error message in here
                    checkIfARKitAvailable()
                }
        }
    }
}
