//
//  OverlayView.swift
//  WhisperType
//

import SwiftUI

struct OverlayView: View {
    var message: String = "Recording..."

    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 20) {
            // Microphone icon with pulsing animation
            ZStack {
                // Pulsing outer circle
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .opacity(isPulsing ? 0 : 1)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: isPulsing
                    )

                // Inner circle
                Circle()
                    .fill(Color.red)
                    .frame(width: 80, height: 80)

                // Microphone icon
                Image(systemName: "mic.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }

            // Message text
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.7))
                )
        }
        .frame(width: 200, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.5))
                .shadow(radius: 10)
        )
        .onAppear {
            isPulsing = true
        }
    }
}

#Preview {
    OverlayView()
}
