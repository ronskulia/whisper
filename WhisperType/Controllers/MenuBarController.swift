//
//  MenuBarController.swift
//  WhisperType
//

import AppKit
import SwiftUI

class MenuBarController: NSObject {
    private var statusItem: NSStatusItem?
    private var recordingController: RecordingController
    private var settingsWindow: NSWindow?

    init(recordingController: RecordingController) {
        self.recordingController = recordingController
        super.init()
        setupMenuBar()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Use microphone symbol
            button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "WhisperType")
            button.image?.isTemplate = true
        }

        setupMenu()
    }

    private func setupMenu() {
        let menu = NSMenu()

        // Recording status item
        let statusMenuItem = NSMenuItem(title: "Ready", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Start/Stop Recording
        let recordItem = NSMenuItem(title: "Start Recording", action: #selector(toggleRecording), keyEquivalent: "r")
        recordItem.target = self
        menu.addItem(recordItem)

        menu.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit WhisperType", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        self.statusItem?.menu = menu

        // Update menu based on recording state
        updateMenu()
    }

    private func updateMenu() {
        guard let menu = statusItem?.menu else { return }

        // Update status item
        if let statusItem = menu.items.first {
            statusItem.title = recordingController.state.displayMessage
        }

        // Update record item
        if let recordItem = menu.item(withTitle: "Start Recording") ?? menu.item(withTitle: "Stop Recording") {
            if recordingController.state.isRecording {
                recordItem.title = "Stop Recording"
            } else {
                recordItem.title = "Start Recording"
            }
            recordItem.isEnabled = !recordingController.state.isProcessing
        }
    }

    @objc private func toggleRecording() {
        recordingController.toggleRecording()
        // Update menu after short delay to reflect state change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateMenu()
        }
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "WhisperType Settings"
            settingsWindow?.styleMask = [.titled, .closable]
            settingsWindow?.setContentSize(NSSize(width: 500, height: 400))
            settingsWindow?.center()
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    // Public method to update menu from external state changes
    func refreshMenu() {
        updateMenu()
    }
}
