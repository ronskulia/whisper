//
//  WhisperTypeApp.swift
//  WhisperType
//

import SwiftUI

@main
struct WhisperTypeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Settings window - accessible from menu bar
        SwiftUI.Settings {
            SettingsView()
        }
    }
}
