//
//  RecordingState.swift
//  WhisperType
//

import Foundation

enum RecordingState: Equatable {
    case idle
    case recording
    case processing
    case error(String)

    var isRecording: Bool {
        if case .recording = self {
            return true
        }
        return false
    }

    var isProcessing: Bool {
        if case .processing = self {
            return true
        }
        return false
    }

    var displayMessage: String {
        switch self {
        case .idle:
            return "Ready"
        case .recording:
            return "Recording..."
        case .processing:
            return "Processing..."
        case .error(let message):
            return "Error: \(message)"
        }
    }
}
