//
//  MenuBarView.swift
//  WhisperType
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var recordingController: RecordingController

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WhisperType")
                .font(.headline)

            Divider()

            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                Text(recordingController.state.displayMessage)
                    .font(.subheadline)
            }

            Divider()

            Button(action: {
                recordingController.toggleRecording()
            }) {
                Text(recordingController.state.isRecording ? "Stop Recording" : "Start Recording")
            }
            .disabled(recordingController.state.isProcessing)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 200)
    }

    private var statusIcon: String {
        switch recordingController.state {
        case .idle:
            return "circle.fill"
        case .recording:
            return "record.circle.fill"
        case .processing:
            return "hourglass"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }

    private var statusColor: Color {
        switch recordingController.state {
        case .idle:
            return .green
        case .recording:
            return .red
        case .processing:
            return .orange
        case .error:
            return .red
        }
    }
}
