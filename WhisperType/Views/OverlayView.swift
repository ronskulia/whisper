//
//  OverlayView.swift
//  WhisperType
//

import SwiftUI

struct OverlayView: View {
    var message: String = "Recording..."

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
        timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            for i in 0..<waveHeights.count {
                waveHeights[i] = CGFloat.random(in: 0.3...1.0)
            }
        }
    }
}

#Preview {
    OverlayView()
}
