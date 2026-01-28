//
//  RecordingController.swift
//  WhisperType
//

import Foundation
import AppKit
import Combine

class RecordingController: ObservableObject {
    @Published var state: RecordingState = .idle
    @Published var currentAudioLevel: Float = 0.0

    private let audioRecorder = AudioRecorder()
    private let whisperEngine = WhisperEngine()
    private let textInserter = TextInserter()

    var overlayWindow: OverlayWindow?

    private var cancellables = Set<AnyCancellable>()
    private var recordingStartTime: Date?

    init() {
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        // Monitor whisper engine loading state
        whisperEngine.$isModelLoaded
            .sink { [weak self] isLoaded in
                if isLoaded {
                    print("Model loaded and ready")
                }
            }
            .store(in: &cancellables)

        // Forward audio level to overlay
        audioRecorder.$currentAudioLevel
            .sink { [weak self] level in
                self?.currentAudioLevel = level
            }
            .store(in: &cancellables)
    }

    func loadWhisperModel() async {
        do {
            try await whisperEngine.loadModel(modelName: Settings.shared.modelName)
        } catch {
            print("Failed to load Whisper model: \(error)")
            await MainActor.run {
                state = .error("Failed to load model")
            }
        }
    }

    func toggleRecording() {
        Task {
            if state.isRecording {
                await stopRecording()
            } else {
                await startRecording()
            }
        }
    }

    private func startRecording() async {
        guard !state.isRecording && !state.isProcessing else {
            print("Already recording or processing")
            return
        }

        guard whisperEngine.isModelLoaded else {
            await MainActor.run {
                state = .error("Model not loaded")
            }
            showErrorAlert("Please wait for the model to load")
            return
        }

        do {
            await MainActor.run {
                state = .recording
                overlayWindow?.show(message: "Recording...")
                recordingStartTime = Date()
            }

            try await audioRecorder.startRecording()

            print("Recording started")
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
                overlayWindow?.hide()
            }
            showErrorAlert(error.localizedDescription)
        }
    }

    private func stopRecording() async {
        guard state.isRecording else {
            return
        }

        // Update state to processing
        await MainActor.run {
            state = .processing
            overlayWindow?.updateMessage("Processing...")
        }

        // Stop recording and get audio buffer
        let audioBuffer = await audioRecorder.stopRecording()

        print("Processing audio buffer with \(audioBuffer.count) samples")

        // Check if we have enough audio
        guard audioBuffer.count > 16000 else { // At least 1 second of audio at 16kHz
            await MainActor.run {
                state = .idle
                overlayWindow?.hide()
            }
            showErrorAlert("Recording too short. Please speak for at least 1 second.")
            return
        }

        // Transcribe
        do {
            let transcription = try await whisperEngine.transcribe(
                audioBuffer,
                language: Settings.shared.language
            )

            // Insert text if not empty
            if !transcription.isEmpty {
                // Calculate recording duration
                let duration = recordingStartTime.map { Date().timeIntervalSince($0) } ?? 0

                // Track stats
                Settings.shared.addRecording(text: transcription, durationSeconds: duration)

                // Paste the text and check if it was kept in clipboard
                let keptInClipboard = textInserter.pasteText(transcription)

                if keptInClipboard {
                    // No active window: show message
                    await MainActor.run {
                        overlayWindow?.updateMessage("Saved - Press ⌘V to paste")
                    }

                    // Keep message visible for 1.5 seconds
                    try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s
                }

                await MainActor.run {
                    state = .idle
                    overlayWindow?.hide()
                }
            } else {
                await MainActor.run {
                    state = .idle
                    overlayWindow?.hide()
                }
                showErrorAlert("No speech detected. Please try again.")
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
                overlayWindow?.hide()
            }
            showErrorAlert(error.localizedDescription)
        }
    }

    private func showErrorAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "WhisperType Error"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    func cleanup() {
        audioRecorder.cleanup()
        whisperEngine.unloadModel()
    }
}
