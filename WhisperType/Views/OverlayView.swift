//
//  OverlayView.swift
//  WhisperType
//

import SwiftUI

struct OverlayView: View {
    var message: String = "Recording..."
    weak var recordingController: RecordingController?
    var onCancel: (() -> Void)?

    @State private var waveHeights: [CGFloat] = Array(repeating: 0.3, count: 8)
    @State private var timer: Timer?

    var body: some View {
        HStack(spacing: 8) {
            // Microphone icon
            Image(systemName: "mic.fill")
                .font(.system(size: 14))
                .foregroundColor(.white)

            // Audio wave bars
            HStack(spacing: 3) {
                ForEach(0..<8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .frame(width: 3, height: 20 * waveHeights[index])
                        .animation(
                            Animation.easeInOut(duration: 0.3),
                            value: waveHeights[index]
                        )
                }
            }

            // Message text (only show if processing)
            if message != "Recording..." {
                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }

            // Cancel button (only show while recording)
            if message == "Recording..." {
                Button(action: {
                    onCancel?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red.opacity(0.9))
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.85))
        )
        .onAppear {
            startWaveAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startWaveAnimation() {
        // Invalidate any existing timer first
        timer?.invalidate()
        timer = nil

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak recordingController] _ in
            // Safety check - make sure we can access the recording controller
            guard let controller = recordingController else {
                return
            }

            let level = controller.currentAudioLevel

            // Much lower threshold for better sensitivity to quiet speech
            let silenceThreshold: Float = 0.002

            // Update wave heights on main thread
            DispatchQueue.main.async { [self] in
                if level < silenceThreshold {
                    // Freeze at low level when silent
                    for i in 0..<waveHeights.count {
                        waveHeights[i] = 0.3
                    }
                } else {
                    // Amplify the audio level more for better visibility
                    let normalizedLevel = min(CGFloat(level * 50), 1.0)
                    for i in 0..<waveHeights.count {
                        let variation = CGFloat.random(in: -0.15...0.15)
                        waveHeights[i] = max(0.4, min(1.0, normalizedLevel + variation))
                    }
                }
            }
        }
    }
}

#Preview {
    OverlayView()
}
