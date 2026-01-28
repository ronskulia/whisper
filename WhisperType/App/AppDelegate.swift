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

        print("WhisperType started successfully")
    }

    func applicationWillTerminate(_ notification: Notification) {
        recordingController?.cleanup()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
