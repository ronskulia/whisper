//
//  TextInserter.swift
//  WhisperType
//

import AppKit
import CoreGraphics

class TextInserter {
    func pasteText(_ text: String) {
        guard !text.isEmpty else {
            print("Empty text, skipping paste")
            return
        }

        print("Pasting text: \(text)")

        // Save current clipboard contents
        let pasteboard = NSPasteboard.general
        let previousContents = pasteboard.pasteboardItems

        // Set new text to clipboard
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Small delay to ensure clipboard is updated
        usleep(50000) // 50ms

        // Simulate Cmd+V
        simulateCmdV()

        // Restore previous clipboard after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            pasteboard.clearContents()
            if let items = previousContents {
                pasteboard.writeObjects(items)
            }
        }

        print("Text pasted successfully")
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
