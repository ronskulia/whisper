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
    private var isModelLoading = true

    init(recordingController: RecordingController) {
        self.recordingController = recordingController
        super.init()
        setupMenuBar()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Start with loading indicator
        updateMenuBarIcon(loading: true)
        setupMenu()
    }

    private func updateMenuBarIcon(loading: Bool) {
        isModelLoading = loading
        if let button = statusItem?.button {
            if loading {
                // Show loading icon (mic with badge)
                button.image = NSImage(systemSymbolName: "mic.badge.ellipsis", accessibilityDescription: "WhisperType - Loading")
            } else {
                // Show ready icon
                button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "WhisperType - Ready")
            }
            button.image?.isTemplate = true
        }
        updateMenu()
    }

    func setModelLoaded() {
        DispatchQueue.main.async {
            self.updateMenuBarIcon(loading: false)
        }
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
            if isModelLoading {
                statusItem.title = "Loading model..."
            } else {
                statusItem.title = recordingController.state.displayMessage
            }
        }

        // Update record item
        if let recordItem = menu.item(withTitle: "Start Recording") ?? menu.item(withTitle: "Stop Recording") {
            if recordingController.state.isRecording {
                recordItem.title = "Stop Recording"
            } else {
                recordItem.title = "Start Recording"
            }
            // Disable recording while model is loading or processing
            recordItem.isEnabled = !isModelLoading && !recordingController.state.isProcessing
        }
    }

    @objc private func toggleRecording() {
        recordingController.toggleRecording()
        // Update menu after short delay to reflect state change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateMenu()
        }
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "WhisperType Settings"
            settingsWindow?.styleMask = [.titled, .closable]
            settingsWindow?.setContentSize(NSSize(width: 550, height: 480))
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
