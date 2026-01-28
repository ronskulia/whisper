//
//  OverlayView.swift
//  WhisperType
//

import SwiftUI

struct OverlayView: View {
    var message: String = "Recording..."
    weak var recordingController: RecordingController?

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
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak recordingController] _ in
            guard let level = recordingController?.currentAudioLevel else { return }

            // Threshold for silence (adjust sensitivity here)
            let silenceThreshold: Float = 0.01

            if level < silenceThreshold {
                // Freeze at low level when silent
                for i in 0..<waveHeights.count {
                    waveHeights[i] = 0.3
                }
            } else {
                // Animate based on audio level when speaking
                let normalizedLevel = min(CGFloat(level * 10), 1.0) // Scale up the level
                for i in 0..<waveHeights.count {
                    let variation = CGFloat.random(in: -0.2...0.2)
                    waveHeights[i] = max(0.3, min(1.0, normalizedLevel + variation))
                }
            }
        }
    }
}

#Preview {
    OverlayView()
}
