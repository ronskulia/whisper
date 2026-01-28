//
//  WhisperTypeApp.swift
//  WhisperType
//

import SwiftUI

@main
struct WhisperTypeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Use Settings scene instead of WindowGroup
        // This doesn't auto-create a window and won't trigger app termination
        SwiftUI.Settings {
            Text("Use menu bar icon to access WhisperType")
                .frame(width: 300, height: 100)
        }
    }
}
