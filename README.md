I didnt want to pay for superwhisper, so just asked claude to create me my own version

# WhisperType

A macOS menu bar app for speech-to-text transcription using WhisperKit. Record audio with a global hotkey and automatically paste transcribed text anywhere.

## Features

- **Menu bar app** - Lives in your menu bar, not in the Dock
- **Global hotkey** - Press `Option+Space` to start/stop recording from anywhere
- **Local transcription** - Uses WhisperKit for completely offline, private transcription
- **Auto-paste** - Transcribed text is automatically pasted at your cursor (and kept in clipboard as backup)
- **Multiple models** - Choose between tiny (fast), base (balanced), or small (accurate)
- **Multi-language** - Supports English, Ukrainian, Spanish, French, German, Italian, Portuguese, Chinese, Japanese, Korean
- **Microphone selection** - Choose which input device to use (built-in mic, AirPods, external mic)
- **Visual feedback** - Animated overlay shows recording status with audio level visualization
- **Cancel recording** - Click the X button on the overlay to cancel without transcribing
- **Speech statistics** - Track your speaking speed, total recordings, and words transcribed

## Requirements

- macOS 13.0 or later
- Apple Silicon (M1/M2/M3) or Intel Mac

## Installation

### Option 1: Using Xcode (Recommended)

1. **Clone the repository:**
```bash
git clone https://github.com/ronskulia/whisper.git
cd whisper/WhisperType
```

2. **Open in Xcode:**
```bash
open WhisperType.xcodeproj
```

3. **Build the app:**
   - Press `Cmd+B` to build (or `Cmd+R` to build and run)
   - Xcode will automatically download WhisperKit and dependencies
   - First build takes 2-3 minutes

4. **Install to Applications:**
   - In Xcode, go to **Product → Show Build Folder in Finder**
   - Navigate to `Products/Release/` (or `Products/Debug/`)
   - Drag `WhisperType.app` to your `/Applications` folder
   - Or copy from: `~/Library/Developer/Xcode/DerivedData/WhisperType-[random]/Build/Products/Release/WhisperType.app`

### Option 2: Command Line

1. **Clone and build:**
```bash
git clone https://github.com/ronskulia/whisper.git
cd whisper/WhisperType
xcodebuild -scheme WhisperType -configuration Release build
```

2. **Find the built app:**
```bash
# The app is built to DerivedData. Find it with:
find ~/Library/Developer/Xcode/DerivedData -name "WhisperType.app" -path "*/Release/*" 2>/dev/null
```

3. **Copy to Applications:**
```bash
# Replace the path with the actual path from the previous command
cp -r ~/Library/Developer/Xcode/DerivedData/WhisperType-*/Build/Products/Release/WhisperType.app /Applications/
```

4. **Launch:**
```bash
open /Applications/WhisperType.app
```

## First Run

On first run, WhisperType will:
1. Request **Microphone** permission (required for recording)
2. Request **Accessibility** permission (required for global hotkeys and pasting text)
3. Download the Whisper model (~39MB for tiny model)

## Usage

1. Press `Option+Space` to start recording (overlay appears at top of screen)
2. Speak clearly into your microphone (waves animate based on your voice)
3. Press `Option+Space` again to stop recording (or click the X to cancel)
4. Wait a moment while the audio is transcribed ("Processing..." appears)
5. The transcribed text is automatically pasted at your cursor
6. If no cursor is active, text stays in clipboard - just press `Cmd+V` to paste anywhere

## Settings

Click the menu bar icon → Settings to access two tabs:

**Settings Tab:**
- Change Whisper model (tiny/base/small)
- Change transcription language
- Select microphone input device
- View permission status (Microphone & Accessibility)

**Stats Tab:**
- View average speaking speed (words per minute)
- See total recordings count
- Track total words transcribed
- Check total recording time

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
