# OneFocus - Setup Instructions

## Quick Start

1. **Extract the ZIP file**
   - Unzip `OneFocus_Refactored.zip` to your desired location

2. **Open in Xcode**
   - Double-click `OneFocus.xcodeproj` to open in Xcode
   - Or open Xcode and select File → Open → Navigate to the project

3. **Configure Signing**
   - Select the OneFocus project in the navigator
   - Select the OneFocus target
   - Go to "Signing & Capabilities" tab
   - Select your development team from the dropdown
   - Xcode will automatically manage provisioning profiles

4. **Build and Run**
   - Press `⌘R` or click the Play button
   - Select your Mac as the destination
   - The app will build and launch

## First Launch Experience

When you first launch the app, you'll go through:

1. **Sign In/Sign Up Screen**
   - Enter your email and password
   - Click "Sign Up" to create a new account
   - Or use "Sign In" if you already have an account

2. **Onboarding Tour**
   - 5 screens showcasing all features
   - Click "Next" to proceed or "Skip" to jump to the app
   - Click "Get Started" on the final screen

3. **Main App**
   - You'll land on the Home page
   - Explore the sidebar navigation on the left
   - Click the profile icon at the bottom for settings

## Project Structure

The project is organized as follows:

```
OneFocus/
├── OneFocusApp.swift          # App entry point
├── Constants.swift            # Design system
├── Models/                    # Data models
├── ViewModels/                # State management
├── Views/                     # All UI views
│   ├── MainView.swift         # Sidebar navigation
│   ├── Auth/                  # Login & onboarding
│   ├── Tabs/                  # Main screens
│   ├── Notes/                 # Quick Notes
│   ├── Clipboard/             # Clipboard History
│   ├── Components/            # Reusable UI
│   └── Shared/                # Common elements
├── Services/                  # Business logic
└── Base/                      # Utilities
```

## Key Files to Review

### Entry Point
- `OneFocusApp.swift` - Main app structure and authentication flow

### Navigation
- `Views/MainView.swift` - Sidebar navigation implementation

### Authentication
- `Models/AuthManager.swift` - Auth state management
- `Views/Auth/SignInView.swift` - Login screen
- `Views/Auth/OnboardingView.swift` - Feature tour

### Main Features
- `Views/Tabs/HomeView.swift` - Dashboard with quick actions
- `Views/Tabs/FocusView.swift` - Pomodoro timer
- `Views/Tabs/TasksView.swift` - Task management
- `Views/Notes/QuickNotesView.swift` - Rich text notes
- `Views/Clipboard/ClipboardHistoryView.swift` - Clipboard tracking

## Customization

### Design System
All design constants are in `Constants.swift`:
- Colors (black and white theme)
- Spacing values
- Corner radius
- Font sizes
- Animation durations

### User Settings
Modify `Models/UserSettings.swift` to add new preferences:
- Timer durations
- Notification settings
- Appearance mode
- Haptic feedback

## Troubleshooting

### Build Errors

**Issue**: "No such module" errors
- **Solution**: Clean build folder (⌘⇧K) and rebuild

**Issue**: Signing errors
- **Solution**: Ensure you've selected a valid development team in Signing & Capabilities

**Issue**: macOS version errors
- **Solution**: Project requires macOS 13.0+. Update deployment target if needed.

### Runtime Issues

**Issue**: Clipboard monitoring not working
- **Solution**: Grant clipboard access in System Settings → Privacy & Security → Clipboard

**Issue**: Notifications not appearing
- **Solution**: Grant notification permissions in System Settings → Notifications → OneFocus

**Issue**: App crashes on launch
- **Solution**: Check Console.app for error logs. May need to reset UserDefaults.

## Development Tips

### Testing
- Use Xcode Previews for rapid UI iteration
- Preview providers are included in most view files
- Press `⌘⌥P` to refresh previews

### Debugging
- Set breakpoints in Xcode
- Use `print()` statements for quick debugging
- Check UserDefaults in ~/Library/Preferences/

### Code Style
- Follow existing Swift style guide
- Use meaningful variable names
- Comment complex logic
- Keep files under 500 lines when possible

## Building for Release

1. **Archive the App**
   - Product → Archive
   - Wait for archive to complete

2. **Export**
   - Click "Distribute App"
   - Choose "Copy App"
   - Select destination folder

3. **Notarization** (for distribution)
   - Requires Apple Developer Program membership
   - Use `xcrun notarytool` for notarization
   - Staple the notarization ticket

## System Requirements

### Development
- macOS 13.0 or later
- Xcode 15.0 or later
- Apple Developer account (for device testing)

### Runtime
- macOS 13.0 or later
- ~50MB disk space
- Internet connection (for authentication, future features)

## Support

### Common Questions

**Q: Can I use this without signing in?**
A: Currently, authentication is required. You can modify `OneFocusApp.swift` to bypass this.

**Q: Where is my data stored?**
A: All data is stored locally in UserDefaults. No cloud sync yet.

**Q: Can I export my notes?**
A: Not yet. This is a planned feature for future versions.

**Q: Does clipboard monitoring work in background?**
A: Yes, as long as the app is running (doesn't need to be in foreground).

### Reporting Issues

If you encounter issues:
1. Check the CHANGELOG.md for known limitations
2. Review the code comments for implementation details
3. Check Xcode console for error messages

## Next Steps

After setup:
1. ✅ Explore all features in the app
2. ✅ Customize settings to your preferences
3. ✅ Review the code to understand the architecture
4. ✅ Make modifications as needed
5. ✅ Test thoroughly before deploying

## Additional Resources

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Platform**: macOS 13+
