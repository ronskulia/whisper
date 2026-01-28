//
//  SettingsView.swift
//  WhisperType
//

import SwiftUI
import AVFoundation
import ApplicationServices

struct SettingsView: View {
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        Form {
            Section(header: Text("General").font(.headline)) {
                Picker("Whisper Model", selection: $settings.modelName) {
                    Text("Tiny (39MB, Fastest)").tag("openai_whisper-tiny")
                    Text("Base (74MB, Balanced)").tag("openai_whisper-base")
                    Text("Small (244MB, Accurate)").tag("openai_whisper-small")
                }

                Picker("Language", selection: $settings.language) {
                    Text("English").tag("en")
                    Text("Ukrainian").tag("uk")
                    Text("Spanish").tag("es")
                    Text("French").tag("fr")
                    Text("German").tag("de")
                    Text("Italian").tag("it")
                    Text("Portuguese").tag("pt")
                    Text("Chinese").tag("zh")
                    Text("Japanese").tag("ja")
                    Text("Korean").tag("ko")
                    Text("Auto-detect").tag("")
                }
            }

            Section(header: Text("Hotkey").font(.headline)) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Hotkey:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("⌥ Option + Space")
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)

                    Text("Hotkey customization coming soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Speech Statistics").font(.headline)) {
                VStack(alignment: .leading, spacing: 12) {
                    StatRow(
                        label: "Average Speaking Speed",
                        value: String(format: "%.0f words/min", settings.speechStats.averageWPM),
                        icon: "speedometer"
                    )

                    StatRow(
                        label: "Total Recordings",
                        value: "\(settings.speechStats.totalRecordings)",
                        icon: "waveform.circle"
                    )

                    StatRow(
                        label: "Total Words Transcribed",
                        value: "\(settings.speechStats.totalWords)",
                        icon: "text.bubble"
                    )

                    StatRow(
                        label: "Total Recording Time",
                        value: settings.speechStats.totalDurationFormatted,
                        icon: "clock"
                    )

                    if settings.speechStats.totalRecordings == 0 {
                        Text("Start recording to see your stats!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }

            Section(header: Text("Permissions").font(.headline)) {
                VStack(alignment: .leading, spacing: 10) {
                    PermissionRow(
                        title: "Microphone",
                        icon: "mic.fill",
                        isGranted: checkMicrophonePermission()
                    )

                    PermissionRow(
                        title: "Accessibility",
                        icon: "accessibility",
                        isGranted: checkAccessibilityPermission()
                    )

                    Button("Open System Settings") {
                        openSystemSettings()
                    }
                }
            }

            Section(header: Text("About").font(.headline)) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("WhisperType")
                        .font(.headline)
                    Text("Version 1.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Powered by WhisperKit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 500, height: 500)
        .onDisappear {
            settings.saveSettings()
        }
    }

    private func checkMicrophonePermission() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return true
        default:
            return false
        }
    }

    private func checkAccessibilityPermission() -> Bool {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false
        ]
        return AXIsProcessTrustedWithOptions(options)
    }

    private func openSystemSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!
        NSWorkspace.shared.open(url)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(.body, weight: .semibold))
            }
            Spacer()
        }
    }
}

struct PermissionRow: View {
    let title: String
    let icon: String
    let isGranted: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isGranted ? .green : .orange)
            Text(title)
            Spacer()
            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isGranted ? .green : .orange)
        }
    }
}

#Preview {
    SettingsView()
}
