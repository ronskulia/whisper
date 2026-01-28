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

        // Initialize controllers (with safe unwrapping)
        let recording = RecordingController()
        recordingController = recording
        menuBarController = MenuBarController(recordingController: recording)
        overlayWindow = OverlayWindow(recordingController: recording)

        // Set up overlay window callback
        recording.overlayWindow = overlayWindow

        // Set up model loaded callback
        recording.onModelLoaded = { [weak self] in
            self?.menuBarController?.setModelLoaded()
        }

        // Set up hotkey
        hotkeyManager = HotkeyManager()
        hotkeyManager?.registerHotkey { [weak self] in
            self?.recordingController?.toggleRecording()
        }

        // Load Whisper model in background
        Task {
            await recording.loadWhisperModel()
        }

        // Open settings on launch (small delay to ensure everything is ready)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.menuBarController?.openSettings()
        }

        print("WhisperType started successfully")
    }

    func applicationWillTerminate(_ notification: Notification) {
        recordingController?.cleanup()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // IMPORTANT: Prevent app from quitting when windows are closed
    // This is essential for menu bar apps
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
