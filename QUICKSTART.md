# WhisperType Quick Start

## What Is This?

WhisperType is a macOS menu bar app that lets you dictate text anywhere using a global hotkey. Press `Control+Space`, speak, and your words are automatically transcribed and pasted at your cursor.

## Installation & First Run

1. **Clone and open:**
   ```bash
   git clone https://github.com/ronskulia/whisper.git
   cd whisper
   open WhisperType.xcodeproj
   ```

2. **Build in Xcode** (press Cmd+R)
   - Xcode automatically downloads dependencies
   - First build takes 2-3 minutes

3. **Grant permissions:**
   - **Microphone**: Required for recording. Click "OK" when prompted.
   - **Accessibility**: Required for hotkey and paste. Click "Open System Settings" and enable WhisperType.

4. **Wait for model download:**
   - First launch downloads the Whisper model (~39MB)
   - Takes 30-60 seconds depending on connection
   - You'll see "Model loaded" when ready

## Basic Usage

1. **Position your cursor** where you want text (any app: Safari, Notes, Slack, etc.)
2. **Press Control+Space** to start recording
3. **Speak clearly** into your microphone
4. **Press Control+Space again** to stop
5. **Wait a moment** - you'll see a "Processing..." overlay
6. **Text appears** automatically at your cursor!

## Tips

- **Speak for at least 1 second** - very short recordings may not transcribe
- **Speak clearly** - the "tiny" model is fast but less accurate than larger models
- **Check your microphone** - make sure the right input is selected in System Settings
- **Be patient** - first transcription may take longer as the model warms up

## Settings

Click the microphone icon in menu bar → Settings to:
- **Change model**: Tiny (fast) → Base (balanced) → Small (accurate)
- **Change language**: English, Spanish, French, German, Italian, etc.
- **Check permissions**: See which permissions are granted

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Hotkey doesn't work | Go to System Settings → Privacy & Security → Accessibility, enable WhisperType |
| Text doesn't paste | Same as above - Accessibility permission required |
| "No speech detected" | Speak louder, check microphone, or speak for longer |
| App not in menu bar | Check that app launched successfully, look for microphone icon top-right |
| Model download fails | Check internet connection, restart app to retry |

## How It Works

1. **Recording**: Uses WhisperKit's AudioProcessor to capture 16kHz mono audio
2. **Transcription**: Runs OpenAI's Whisper model **locally** (no internet needed after download)
3. **Pasting**: Copies to clipboard, simulates Cmd+V, restores original clipboard

## Privacy

- **Everything is local** - audio never leaves your Mac
- **No servers** - transcription happens on-device
- **No data collection** - your recordings aren't stored or sent anywhere

## Files

- **WhisperType.app** - The app (in DerivedData after building)
- **README.md** - Detailed documentation
- **IMPLEMENTATION.md** - Technical implementation details
- **run.sh** - Build and run script

## Next Steps

Once you're comfortable with basic usage:
- Try different models in Settings (base is more accurate than tiny)
- Use in different apps - works everywhere!
- Try other languages if you're multilingual

## Support

If something doesn't work:
1. Check permissions in System Settings
2. Restart the app
3. Check console for error messages
4. See IMPLEMENTATION.md for architecture details

Enjoy dictating!
