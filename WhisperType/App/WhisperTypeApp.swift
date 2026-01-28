//
//  WhisperTypeApp.swift
//  WhisperType
//

import SwiftUI

@main
struct WhisperTypeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar app - no window needed
        WindowGroup {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
