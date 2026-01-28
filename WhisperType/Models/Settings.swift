//
//  Settings.swift
//  WhisperType
//

import Foundation
import Carbon

// MARK: - Speech Statistics

struct SpeechStats: Codable {
    var totalRecordings: Int = 0
    var totalWords: Int = 0
    var totalDurationSeconds: Double = 0.0
    var recordings: [RecordingData] = []

    var averageWPM: Double {
        guard totalDurationSeconds > 0 else { return 0 }
        let minutes = totalDurationSeconds / 60.0
        return Double(totalWords) / minutes
    }

    var totalDurationFormatted: String {
        let minutes = Int(totalDurationSeconds) / 60
        let seconds = Int(totalDurationSeconds) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    mutating func addRecording(words: Int, durationSeconds: Double) {
        totalRecordings += 1
        totalWords += words
        totalDurationSeconds += durationSeconds

        let recording = RecordingData(
            date: Date(),
            words: words,
            durationSeconds: durationSeconds
        )
        recordings.append(recording)

        // Keep only last 100 recordings
        if recordings.count > 100 {
            recordings.removeFirst()
        }
    }
}

struct RecordingData: Codable {
    let date: Date
    let words: Int
    let durationSeconds: Double

    var wpm: Double {
        guard durationSeconds > 0 else { return 0 }
        let minutes = durationSeconds / 60.0
        return Double(words) / minutes
    }
}

// MARK: - Settings

class Settings: ObservableObject {
    static let shared = Settings()

    @Published var hotkeyKeyCode: UInt32 = UInt32(kVK_Space)
    @Published var hotkeyModifiers: UInt32 = UInt32(cmdKey | shiftKey)
    @Published var modelName: String = "openai_whisper-base"
    @Published var language: String = "en"
    @Published var speechStats: SpeechStats = SpeechStats()

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
        if let data = UserDefaults.standard.data(forKey: "speechStats"),
           let stats = try? JSONDecoder().decode(SpeechStats.self, from: data) {
            speechStats = stats
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(hotkeyKeyCode, forKey: "hotkeyKeyCode")
        UserDefaults.standard.set(hotkeyModifiers, forKey: "hotkeyModifiers")
        UserDefaults.standard.set(modelName, forKey: "modelName")
        UserDefaults.standard.set(language, forKey: "language")

        if let data = try? JSONEncoder().encode(speechStats) {
            UserDefaults.standard.set(data, forKey: "speechStats")
        }
    }

    func addRecording(text: String, durationSeconds: Double) {
        let wordCount = text.split(separator: " ").count
        speechStats.addRecording(words: wordCount, durationSeconds: durationSeconds)
        saveSettings()
    }
}
