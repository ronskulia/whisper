//
//  WhisperEngine.swift
//  WhisperType
//

import Foundation
import WhisperKit

class WhisperEngine: ObservableObject {
    private var whisperKit: WhisperKit?
    @Published var isModelLoaded = false
    @Published var loadingProgress: String = ""

    func loadModel(modelName: String = "openai_whisper-tiny") async throws {
        print("Loading Whisper model: \(modelName)")

        await MainActor.run {
            loadingProgress = "Loading model..."
        }

        let config = WhisperKitConfig(
            model: modelName,
            computeOptions: ModelComputeOptions(),
            verbose: false,
            logLevel: .info,
            prewarm: true,
            load: true,
            download: true
        )

        do {
            whisperKit = try await WhisperKit(config)

            await MainActor.run {
                isModelLoaded = true
                loadingProgress = "Model loaded"
            }

            print("Whisper model loaded successfully")
        } catch {
            await MainActor.run {
                loadingProgress = "Failed to load model"
            }
            print("Failed to load model: \(error)")
            throw WhisperError.modelLoadFailed(error.localizedDescription)
        }
    }

    func transcribe(_ audioSamples: [Float], language: String = "en") async throws -> String {
        guard let whisperKit = whisperKit else {
            throw WhisperError.modelNotLoaded
        }

        guard !audioSamples.isEmpty else {
            throw WhisperError.emptyAudio
        }

        print("Starting transcription, samples: \(audioSamples.count)")

        let options = DecodingOptions(
            task: .transcribe,
            language: language,
            temperature: 0.0,
            temperatureIncrementOnFallback: 0.2,
            temperatureFallbackCount: 5,
            sampleLength: 224,
            topK: 5,
            usePrefillPrompt: true,
            usePrefillCache: true,
            skipSpecialTokens: true,
            withoutTimestamps: true,
            clipTimestamps: [],
            chunkingStrategy: nil
        )

        do {
            let results = try await whisperKit.transcribe(
                audioArray: audioSamples,
                decodeOptions: options
            )

            guard let transcription = results.first else {
                throw WhisperError.transcriptionFailed("No results returned")
            }

            let text = transcription.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            print("Transcription complete: \(text)")

            return text
        } catch {
            print("Transcription error: \(error)")
            throw WhisperError.transcriptionFailed(error.localizedDescription)
        }
    }

    func unloadModel() {
        whisperKit = nil
        isModelLoaded = false
        print("Whisper model unloaded")
    }
}

enum WhisperError: Error, LocalizedError {
    case modelNotLoaded
    case modelLoadFailed(String)
    case emptyAudio
    case transcriptionFailed(String)

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Whisper model is not loaded. Please wait for initialization."
        case .modelLoadFailed(let reason):
            return "Failed to load Whisper model: \(reason)"
        case .emptyAudio:
            return "No audio recorded. Please try again."
        case .transcriptionFailed(let reason):
            return "Transcription failed: \(reason)"
        }
    }
}
