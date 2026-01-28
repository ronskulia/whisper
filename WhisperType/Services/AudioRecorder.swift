//
//  AudioRecorder.swift
//  WhisperType
//

import Foundation
import AVFoundation
import WhisperKit

class AudioRecorder: ObservableObject {
    private var audioProcessor: AudioProcessor?
    @Published var isRecording = false
    @Published var currentAudioLevel: Float = 0.0
    private var audioBuffer: [Float] = []

    init() {
        audioProcessor = AudioProcessor()
    }

    func startRecording() async throws {
        // Request microphone permission
        guard await requestMicrophonePermission() else {
            throw RecordingError.noPermission
        }

        // Clear previous buffer
        audioBuffer = []

        // Start recording with live audio callback
        try audioProcessor?.startRecordingLive { [weak self] buffer in
            guard let self = self else { return }
            // Append to buffer
            self.audioBuffer.append(contentsOf: buffer)

            // Calculate RMS (root mean square) for audio level
            if !buffer.isEmpty {
                let sumOfSquares = buffer.map { $0 * $0 }.reduce(0, +)
                let rms = sqrt(sumOfSquares / Float(buffer.count))

                Task { @MainActor in
                    self.currentAudioLevel = rms
                }
            }
        }

        await MainActor.run {
            isRecording = true
        }

        print("Recording started")
    }

    func stopRecording() async -> [Float] {
        audioProcessor?.stopRecording()

        await MainActor.run {
            isRecording = false
        }

        print("Recording stopped, buffer size: \(audioBuffer.count) samples")

        return audioBuffer
    }

    private func requestMicrophonePermission() async -> Bool {
        return await AudioProcessor.requestRecordPermission()
    }

    func cleanup() {
        if isRecording {
            audioProcessor?.stopRecording()
        }
    }
}

enum RecordingError: Error, LocalizedError {
    case noPermission
    case audioEngineError
    case invalidBuffer

    var errorDescription: String? {
        switch self {
        case .noPermission:
            return "Microphone permission denied. Please grant permission in System Settings."
        case .audioEngineError:
            return "Failed to start audio recording engine."
        case .invalidBuffer:
            return "Invalid audio buffer received."
        }
    }
}
