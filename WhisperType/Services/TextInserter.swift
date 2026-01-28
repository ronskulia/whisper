//
//  TextInserter.swift
//  WhisperType
//

import AppKit
import CoreGraphics

class TextInserter {
    // Returns true if text was kept in clipboard (no active window), false if pasted normally
    func pasteText(_ text: String) -> Bool {
        guard !text.isEmpty else {
            print("Empty text, skipping paste")
            return false
        }

        print("Pasting text: \(text)")

        // Check if there's an active window to paste into
        let hasActiveWindow = checkForActiveWindow()

        let pasteboard = NSPasteboard.general

        // Save the ACTUAL DATA from clipboard (not just references to items)
        // NSPasteboardItem references become invalid after clearContents()
        var previousString: String? = nil
        if let str = pasteboard.string(forType: .string) {
            previousString = str
        }

        // Set text to clipboard
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Small delay to ensure clipboard is updated
        usleep(50000) // 50ms

        // Simulate Cmd+V
        simulateCmdV()

        if hasActiveWindow {
            // Normal case: restore previous clipboard after paste
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                pasteboard.clearContents()
                if let str = previousString {
                    pasteboard.setString(str, forType: .string)
                }
            }
            print("Text pasted to active window, clipboard restored")
            return false
        } else {
            // No active window: keep text in clipboard for manual paste
            print("No active window, text kept in clipboard")
            return true
        }
    }

    private func checkForActiveWindow() -> Bool {
        // Check if there's a frontmost application that can receive input
        guard let frontApp = NSWorkspace.shared.frontmostApplication else {
            return false
        }

        // Exclude our own app and system apps that don't accept text input
        let bundleId = frontApp.bundleIdentifier ?? ""
        let excludedApps = ["com.apple.finder", "com.apple.dock"]

        return !excludedApps.contains(bundleId) && bundleId != Bundle.main.bundleIdentifier
    }

    private func simulateCmdV() {
        let source = CGEventSource(stateID: .hidSystemState)

        // Key codes
        let cmdKeyCode: CGKeyCode = 0x37  // Command key
        let vKeyCode: CGKeyCode = 0x09    // V key

        // Create events
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: cmdKeyCode, keyDown: true)
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: cmdKeyCode, keyDown: false)

        // Set command flag on v key events
        vDown?.flags = .maskCommand
        vUp?.flags = .maskCommand

        // Post events
        cmdDown?.post(tap: .cghidEventTap)
        usleep(10000) // 10ms delay
        vDown?.post(tap: .cghidEventTap)
        usleep(10000) // 10ms delay
        vUp?.post(tap: .cghidEventTap)
        usleep(10000) // 10ms delay
        cmdUp?.post(tap: .cghidEventTap)
    }

    func insertTextDirectly(_ text: String) {
        // Alternative method: type each character
        // This can be used as fallback if paste doesn't work
        for char in text {
            typeCharacter(char)
        }
    }

    private func typeCharacter(_ char: Character) {
        let string = String(char)

        guard let keyCode = characterToKeyCode(char) else {
            return
        }

        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)

        keyDown?.post(tap: .cghidEventTap)
        usleep(10000)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func characterToKeyCode(_ char: Character) -> CGKeyCode? {
        // Basic character to key code mapping
        let keyMap: [Character: CGKeyCode] = [
            "a": 0x00, "b": 0x0B, "c": 0x08, "d": 0x02, "e": 0x0E,
            "f": 0x03, "g": 0x05, "h": 0x04, "i": 0x22, "j": 0x26,
            "k": 0x28, "l": 0x25, "m": 0x2E, "n": 0x2D, "o": 0x1F,
            "p": 0x23, "q": 0x0C, "r": 0x0F, "s": 0x01, "t": 0x11,
            "u": 0x20, "v": 0x09, "w": 0x0D, "x": 0x07, "y": 0x10,
            "z": 0x06,
            " ": 0x31, // Space
        ]

        return keyMap[Character(char.lowercased())]
    }
}
