//
//  AppDelegate.swift
//  WhisperType
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?
    var recordingController: RecordingController?
    var hotkeyManager: HotkeyManager?
    var overlayWindow: OverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - menu bar only
        NSApp.setActivationPolicy(.accessory)

        // Initialize controllers
        recordingController = RecordingController()
        menuBarController = MenuBarController(recordingController: recordingController!)
        overlayWindow = OverlayWindow(recordingController: recordingController)

        // Set up overlay window callback
        recordingController?.overlayWindow = overlayWindow

        // Set up hotkey
        hotkeyManager = HotkeyManager()
        hotkeyManager?.registerHotkey { [weak self] in
            self?.recordingController?.toggleRecording()
        }

        // Load Whisper model in background
        Task {
            await recordingController?.loadWhisperModel()
        }

        // Open settings on launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.openSettings()
        }

        print("WhisperType started successfully")
    }

    private func openSettings() {
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }

        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        recordingController?.cleanup()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
