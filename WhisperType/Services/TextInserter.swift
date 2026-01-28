//
//  TextInserter.swift
//  WhisperType
//

import AppKit
import CoreGraphics

class TextInserter {
    // Returns true if should show "Saved to clipboard" message (on desktop/Finder)
    func pasteText(_ text: String) -> Bool {
        guard !text.isEmpty else {
            print("Empty text, skipping paste")
            return false
        }

        print("Pasting text: \(text)")

        let pasteboard = NSPasteboard.general

        // Set text to clipboard
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Small delay to ensure clipboard is updated
        usleep(50000) // 50ms

        // Simulate Cmd+V (will work if cursor is in a text field, otherwise no-op)
        simulateCmdV()

        // Text ALWAYS stays in clipboard - user can manually Cmd+V if auto-paste didn't work
        // Only show "Saved" message if on desktop (Finder) since paste definitely won't work there
        let showMessage = isOnDesktop()

        if showMessage {
            print("On desktop, text kept in clipboard")
        } else {
            print("Attempted paste, text kept in clipboard as backup")
        }

        return showMessage
    }

    private func isOnDesktop() -> Bool {
        // Check if Finder is frontmost (user is on desktop or in Finder)
        guard let frontApp = NSWorkspace.shared.frontmostApplication else {
            return true // No app = probably desktop
        }

        let bundleId = frontApp.bundleIdentifier ?? ""
        return bundleId == "com.apple.finder" || bundleId == "com.apple.dock"
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
