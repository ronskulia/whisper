//
//  Settings.swift
//  WhisperType
//

import Foundation
import Carbon
import AVFoundation
import CoreAudio

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

// MARK: - Audio Device

struct AudioDevice: Identifiable, Hashable {
    let id: AudioDeviceID
    let name: String
    let uid: String
}

class Settings: ObservableObject {
    static let shared = Settings()

    @Published var hotkeyKeyCode: UInt32 = UInt32(kVK_Space)
    @Published var hotkeyModifiers: UInt32 = UInt32(cmdKey | shiftKey)
    @Published var modelName: String = "openai_whisper-small"
    @Published var language: String = "en"
    @Published var speechStats: SpeechStats = SpeechStats()
    @Published var selectedMicrophoneUID: String = "" // Empty = system default

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
        if let micUID = UserDefaults.standard.string(forKey: "selectedMicrophoneUID") {
            selectedMicrophoneUID = micUID
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(hotkeyKeyCode, forKey: "hotkeyKeyCode")
        UserDefaults.standard.set(hotkeyModifiers, forKey: "hotkeyModifiers")
        UserDefaults.standard.set(modelName, forKey: "modelName")
        UserDefaults.standard.set(language, forKey: "language")
        UserDefaults.standard.set(selectedMicrophoneUID, forKey: "selectedMicrophoneUID")

        if let data = try? JSONEncoder().encode(speechStats) {
            UserDefaults.standard.set(data, forKey: "speechStats")
        }
    }

    // MARK: - Microphone Selection

    func getAvailableInputDevices() -> [AudioDevice] {
        var devices: [AudioDevice] = []

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        )

        guard status == noErr else { return devices }

        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceIDs
        )

        guard status == noErr else { return devices }

        for deviceID in deviceIDs {
            // Check if device has input channels
            var inputChannelsAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyStreamConfiguration,
                mScope: kAudioDevicePropertyScopeInput,
                mElement: kAudioObjectPropertyElementMain
            )

            var inputDataSize: UInt32 = 0
            status = AudioObjectGetPropertyDataSize(deviceID, &inputChannelsAddress, 0, nil, &inputDataSize)

            if status == noErr && inputDataSize > 0 {
                let bufferListPointer = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1)
                defer { bufferListPointer.deallocate() }

                status = AudioObjectGetPropertyData(deviceID, &inputChannelsAddress, 0, nil, &inputDataSize, bufferListPointer)

                if status == noErr {
                    let bufferList = bufferListPointer.pointee
                    var inputChannels: UInt32 = 0
                    let buffers = UnsafeMutableAudioBufferListPointer(UnsafeMutablePointer(mutating: bufferListPointer))
                    for buffer in buffers {
                        inputChannels += buffer.mNumberChannels
                    }

                    if inputChannels > 0 {
                        // Get device name
                        var nameAddress = AudioObjectPropertyAddress(
                            mSelector: kAudioDevicePropertyDeviceNameCFString,
                            mScope: kAudioObjectPropertyScopeGlobal,
                            mElement: kAudioObjectPropertyElementMain
                        )

                        var name: CFString = "" as CFString
                        var nameSize = UInt32(MemoryLayout<CFString>.size)
                        AudioObjectGetPropertyData(deviceID, &nameAddress, 0, nil, &nameSize, &name)

                        // Get device UID
                        var uidAddress = AudioObjectPropertyAddress(
                            mSelector: kAudioDevicePropertyDeviceUID,
                            mScope: kAudioObjectPropertyScopeGlobal,
                            mElement: kAudioObjectPropertyElementMain
                        )

                        var uid: CFString = "" as CFString
                        var uidSize = UInt32(MemoryLayout<CFString>.size)
                        AudioObjectGetPropertyData(deviceID, &uidAddress, 0, nil, &uidSize, &uid)

                        devices.append(AudioDevice(
                            id: deviceID,
                            name: name as String,
                            uid: uid as String
                        ))
                    }
                }
            }
        }

        return devices
    }

    func setDefaultInputDevice(uid: String) {
        let devices = getAvailableInputDevices()
        guard let device = devices.first(where: { $0.uid == uid }) else { return }

        var deviceID = device.id
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            UInt32(MemoryLayout<AudioDeviceID>.size),
            &deviceID
        )
    }

    func addRecording(text: String, durationSeconds: Double) {
        let wordCount = text.split(separator: " ").count
        speechStats.addRecording(words: wordCount, durationSeconds: durationSeconds)
        saveSettings()
    }
}
