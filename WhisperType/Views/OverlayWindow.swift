//
//  OverlayWindow.swift
//  WhisperType
//

import AppKit
import SwiftUI

// Observable object to manage overlay state and animation
class OverlayState: ObservableObject {
    @Published var message: String = "Recording..."
    @Published var waveHeights: [CGFloat] = Array(repeating: 0.3, count: 8)
    @Published var isVisible: Bool = false

    private var timer: Timer?
    weak var recordingController: RecordingController?

    func startAnimation() {
        isVisible = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateWaveHeights()
        }
    }

    func stopAnimation() {
        isVisible = false
        timer?.invalidate()
        timer = nil
        // Reset wave heights
        waveHeights = Array(repeating: 0.3, count: 8)
    }

    private func updateWaveHeights() {
        guard let level = recordingController?.currentAudioLevel else { return }

        let silenceThreshold: Float = 0.002

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if level < silenceThreshold {
                for i in 0..<self.waveHeights.count {
                    self.waveHeights[i] = 0.3
                }
            } else {
                let normalizedLevel = min(CGFloat(level * 50), 1.0)
                for i in 0..<self.waveHeights.count {
                    let variation = CGFloat.random(in: -0.15...0.15)
                    self.waveHeights[i] = max(0.4, min(1.0, normalizedLevel + variation))
                }
            }
        }
    }
}

class OverlayWindow: NSWindow {
    private var hostingView: NSHostingView<OverlayContentView>?
    private let overlayState = OverlayState()
    weak var recordingController: RecordingController?

    init(recordingController: RecordingController? = nil) {
        self.recordingController = recordingController
        overlayState.recordingController = recordingController

        // Create window with no title bar, always on top
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 250, height: 50),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // Configure window properties
        self.isOpaque = false
        self.backgroundColor = .clear
        // Use higher window level to stay above most apps
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false
        self.hasShadow = true
        self.ignoresMouseEvents = false

        // Create the content view (won't be recreated on message updates)
        let contentView = OverlayContentView(
            state: overlayState,
            onCancel: { [weak self] in
                self?.recordingController?.cancelRecording()
            }
        )
        hostingView = NSHostingView(rootView: contentView)
        hostingView?.frame = self.contentView?.bounds ?? .zero
        hostingView?.autoresizingMask = [.width, .height]

        if let hostingView = hostingView {
            self.contentView?.addSubview(hostingView)
        }
    }

    func show(message: String = "Recording...") {
        overlayState.message = message
        overlayState.startAnimation()
        centerOnScreen()
        self.orderFrontRegardless()
    }

    func hide() {
        overlayState.stopAnimation()
        self.orderOut(nil)
    }

    func updateMessage(_ message: String) {
        overlayState.message = message
    }

    private func centerOnScreen() {
        // Get the screen, with fallback
        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            return
        }

        let screenFrame = screen.visibleFrame
        let windowFrame = self.frame
        let x = screenFrame.midX - windowFrame.width / 2
        // Position at top of screen with small margin
        let y = screenFrame.maxY - windowFrame.height - 10
        self.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

// Wrapper view that observes the state
struct OverlayContentView: View {
    @ObservedObject var state: OverlayState
    var onCancel: (() -> Void)?

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
                        .frame(width: 3, height: 20 * state.waveHeights[index])
                        .animation(.easeInOut(duration: 0.15), value: state.waveHeights[index])
                }
            }

            // Message text (only show if not recording)
            if state.message != "Recording..." {
                Text(state.message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }

            // Cancel button (only show while recording)
            if state.message == "Recording..." {
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
    }
}
