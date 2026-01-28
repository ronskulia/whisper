//
//  HotkeyManager.swift
//  WhisperType
//

import Foundation
import AppKit
import HotKey
import ApplicationServices

class HotkeyManager {
    private var hotKey: HotKey?

    func registerHotkey(handler: @escaping () -> Void) {
        // Default: Option+Space
        let key = Key.space
        let modifiers: NSEvent.ModifierFlags = [.option]

        hotKey = HotKey(key: key, modifiers: modifiers)

        hotKey?.keyDownHandler = { [weak self] in
            guard let self = self else { return }

            // Check accessibility permissions
            if !self.checkAccessibilityPermissions() {
                self.promptForAccessibilityPermissions()
                return
            }

            handler()
        }

        print("Hotkey registered: Option+Space")
    }

    func unregister() {
        hotKey = nil
        print("Hotkey unregistered")
    }

    func checkAccessibilityPermissions() -> Bool {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false
        ]
        return AXIsProcessTrustedWithOptions(options)
    }

    func promptForAccessibilityPermissions() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = """
        WhisperType needs Accessibility permission to:
        • Register global hotkeys
        • Paste transcribed text

        Click "Open System Settings" to grant permission, then restart WhisperType.
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openAccessibilitySettings()
        }
    }

    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    func updateHotkey(key: Key, modifiers: NSEvent.ModifierFlags, handler: @escaping () -> Void) {
        unregister()
        hotKey = HotKey(key: key, modifiers: modifiers)
        hotKey?.keyDownHandler = handler
        print("Hotkey updated to: \(key) with modifiers")
    }
}
