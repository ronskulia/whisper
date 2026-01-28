//
//  OverlayWindow.swift
//  WhisperType
//

import AppKit
import SwiftUI

class OverlayWindow: NSWindow {
    private var hostingView: NSHostingView<OverlayView>?
    weak var recordingController: RecordingController?

    init(recordingController: RecordingController? = nil) {
        self.recordingController = recordingController
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
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.isMovableByWindowBackground = false
        self.hasShadow = true

        // Create and set the SwiftUI view
        let overlayView = OverlayView(
            recordingController: recordingController,
            onCancel: { [weak self] in
                self?.recordingController?.cancelRecording()
            }
        )
        hostingView = NSHostingView(rootView: overlayView)
        hostingView?.frame = self.contentView?.bounds ?? .zero
        hostingView?.autoresizingMask = [.width, .height]

        if let hostingView = hostingView {
            self.contentView?.addSubview(hostingView)
        }

        // Center window on screen
        self.center()
    }

    func show(message: String = "Recording...") {
        updateMessage(message)
        centerOnScreen()
        self.orderFrontRegardless()
        self.makeKey()
    }

    func hide() {
        self.orderOut(nil)
    }

    func updateMessage(_ message: String) {
        if let hostingView = hostingView {
            hostingView.rootView = OverlayView(
                message: message,
                recordingController: recordingController,
                onCancel: { [weak self] in
                    self?.recordingController?.cancelRecording()
                }
            )
        }
    }

    private func centerOnScreen() {
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let windowFrame = self.frame
            let x = screenFrame.midX - windowFrame.width / 2
            // Position at top of screen with small margin
            let y = screenFrame.maxY - windowFrame.height - 40
            self.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
}
