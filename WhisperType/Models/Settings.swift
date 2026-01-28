//
//  Settings.swift
//  WhisperType
//

import Foundation
import Carbon

class Settings: ObservableObject {
    static let shared = Settings()

    @Published var hotkeyKeyCode: UInt32 = UInt32(kVK_Space)
    @Published var hotkeyModifiers: UInt32 = UInt32(cmdKey | shiftKey)
    @Published var modelName: String = "openai_whisper-base"
    @Published var language: String = "en"

    private init() {
        loadSettings()
    }

    private func loadSettings() {
        if let keyCode = UserDefaults.standard.object(forKey: "hotkeyKeyCode") as? UInt32 {
            hotkeyKeyCode = keyCode
        }
        if let modifiers = UserDefaults.standard.object(forKey: "hotkeyModifiers") as? UInt32 {
            hotkeyModifiers = modifiers
        }
        if let model = UserDefaults.standard.string(forKey: "modelName") {
            modelName = model
        }
        if let lang = UserDefaults.standard.string(forKey: "language") {
            language = lang
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(hotkeyKeyCode, forKey: "hotkeyKeyCode")
        UserDefaults.standard.set(hotkeyModifiers, forKey: "hotkeyModifiers")
        UserDefaults.standard.set(modelName, forKey: "modelName")
        UserDefaults.standard.set(language, forKey: "language")
    }
}
