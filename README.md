# WhisperType

A macOS menu bar app for speech-to-text transcription using WhisperKit. Record audio with a global hotkey and automatically paste transcribed text anywhere.

## Features

- **Menu bar app** - Lives in your menu bar, not in the Dock
- **Global hotkey** - Press `Control+Space` to start/stop recording from anywhere
- **Local transcription** - Uses WhisperKit for completely offline, private transcription
- **Auto-paste** - Transcribed text is automatically pasted at your cursor
- **Multiple models** - Choose between tiny (fast), base (balanced), or small (accurate)
- **Multi-language** - Supports English, Spanish, French, German, Italian, Portuguese, Chinese, Japanese, Korean

## Requirements

- macOS 13.0 or later
- Apple Silicon (M1/M2/M3) or Intel Mac

## Quick Start

1. **Clone the repository:**
```bash
git clone https://github.com/ronskulia/whisper.git
cd whisper
```

2. **Open in Xcode:**
```bash
open WhisperType.xcodeproj
```

3. **Build and run** (Cmd+R)
   - Xcode will automatically download WhisperKit and dependencies
   - First build takes 2-3 minutes

Or build from command line:
```bash
xcodebuild -scheme WhisperType -configuration Debug build
```

## First Run

On first run, WhisperType will:
1. Request **Microphone** permission (required for recording)
2. Request **Accessibility** permission (required for global hotkeys and pasting text)
3. Download the Whisper model (~39MB for tiny model)

## Usage

1. Press `Control+Space` to start recording
2. Speak clearly into your microphone
3. Press `Control+Space` again to stop recording
4. Wait a moment while the audio is transcribed
5. The transcribed text will be automatically pasted at your cursor

## Settings

Click the menu bar icon → Settings to:
- Change Whisper model (tiny/base/small)
- Change transcription language
- View permission status

## Architecture

```
WhisperType/
├── App/
│   ├── WhisperTypeApp.swift      # App entry point
│   └── AppDelegate.swift          # App lifecycle, wires controllers
├── Controllers/
│   ├── MenuBarController.swift    # Menu bar UI
│   └── RecordingController.swift  # Orchestrates recording → transcription → paste
├── Services/
│   ├── AudioRecorder.swift        # AVAudioEngine recording
│   ├── WhisperEngine.swift        # WhisperKit integration
│   ├── HotkeyManager.swift        # Global hotkey registration
│   └── TextInserter.swift         # CGEvent-based paste simulation
├── Views/
│   ├── OverlayWindow.swift        # Floating recording indicator
│   ├── OverlayView.swift          # SwiftUI recording animation
│   └── SettingsView.swift         # Settings UI
└── Models/
    ├── RecordingState.swift       # State machine for recording
    └── Settings.swift              # User preferences
```

## Dependencies

- **WhisperKit** - https://github.com/argmaxinc/whisperkit (automatically downloaded by Xcode)
- **HotKey** - https://github.com/soffes/HotKey (for global hotkeys)

## Technical Details

- Uses WhisperKit's `AudioProcessor` for 16kHz mono audio recording
- Transcribes using WhisperKit's Swift API
- Pastes text using CGEvent keyboard simulation
- Preserves clipboard contents before/after paste
- Menu bar app (LSUIElement=true, no dock icon)

## License

See LICENSE file for details.

## Troubleshooting

### Hotkey not working
- Go to System Settings → Privacy & Security → Accessibility
- Ensure WhisperType is enabled

### Paste not working
- Same as above - Accessibility permission is required for paste simulation

### No speech detected
- Speak for at least 1 second
- Check microphone input level in System Settings
- Try speaking louder or closer to the microphone

### Model download failed
- Check internet connection
- Model files are cached in WhisperKit's default location
- Restart the app to retry download
