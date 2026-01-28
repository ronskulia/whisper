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
        TabView {
            // Stats Tab
            statsTab
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            // Settings Tab
            settingsTab
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .frame(width: 550, height: 480)
        .onDisappear {
            settings.saveSettings()
        }
    }

    var statsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Speech Statistics")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 16) {
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
                            .padding(.top, 8)
                    }
                }
            }
            .padding(20)
        }
    }

    var settingsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // General Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("General")
                        .font(.headline)
                        .padding(.bottom, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Whisper Model")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Picker("", selection: $settings.modelName) {
                            Text("Tiny (39MB, Fastest)").tag("openai_whisper-tiny")
                            Text("Base (74MB, Balanced)").tag("openai_whisper-base")
                            Text("Small (244MB, Accurate)").tag("openai_whisper-small")
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Language")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Picker("", selection: $settings.language) {
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
                        .pickerStyle(.menu)
                    }
                }

                Divider()

                // Hotkey Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hotkey")
                        .font(.headline)
                        .padding(.bottom, 4)

                    Text("Current Hotkey:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("⌥ Option + Space")
                        .font(.system(.body, design: .monospaced))
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)

                    Text("Hotkey customization coming soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Permissions Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Permissions")
                        .font(.headline)
                        .padding(.bottom, 4)

                    PermissionRow(
                        title: "Microphone",
                        icon: "mic.fill",
                        isGranted: checkMicrophonePermission()
                    )
                    .padding(.vertical, 4)

                    PermissionRow(
                        title: "Accessibility",
                        icon: "accessibility",
                        isGranted: checkAccessibilityPermission()
                    )
                    .padding(.vertical, 4)

                    Button("Open System Settings") {
                        openSystemSettings()
                    }
                    .padding(.top, 4)
                }

                Divider()

                // About Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                        .padding(.bottom, 4)

                    Text("WhisperType")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Version 1.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Powered by WhisperKit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
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
