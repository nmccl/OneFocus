# OneFocus - macOS Productivity App

A minimalist productivity application for macOS 13+ with focus sessions, task management, quick notes, and clipboard history.

## Features

### ✨ Core Features
- **Sidebar Navigation**: Clean left sidebar with easy access to all features
- **Focus Sessions**: Pomodoro-style timer with customizable durations
- **Task Management**: Organize tasks with priorities, due dates, and notes
- **Quick Notes**: Auto-saving rich text notes with formatting tools
- **Clipboard History**: Automatic clipboard monitoring and history
- **User Authentication**: Sign in/sign up with onboarding flow
- **Statistics**: Track your productivity and focus time

### 🎨 Design
- Minimalist Apple-like design
- White background with black accents
- Subtle shadows and borders
- Clean, professional interface
- Light/Dark mode support

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Installation

1. Open `OneFocus.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run the project (⌘R)

## Project Structure

```
OneFocus/
├── OneFocusApp.swift          # Main app entry point
├── Constants.swift            # Design system constants
├── Models/                    # Data models
│   ├── AuthManager.swift
│   ├── ClipboardItem.swift
│   ├── Note.swift
│   ├── Task.swift
│   └── UserSettings.swift
├── ViewModels/                # View models
│   ├── FocusViewModel.swift
│   └── TasksViewModel.swift
├── Views/                     # SwiftUI views
│   ├── MainView.swift         # Main sidebar navigation
│   ├── Auth/                  # Authentication views
│   ├── Tabs/                  # Main content views
│   ├── Notes/                 # Quick Notes feature
│   ├── Clipboard/             # Clipboard history
│   ├── Components/            # Reusable components
│   └── Shared/                # Shared UI elements
├── Services/                  # Business logic services
└── Base/                      # Utilities and helpers
```

## Key Changes from Previous Version

1. **Navigation**: Changed from top tab bar to left sidebar navigation
2. **Removed Pages**: Stats, Profile, and Settings pages moved to dropdown menu
3. **User Profile**: Added profile icon at bottom of sidebar with dropdown
4. **Homepage**: All buttons now have working functionality
5. **Fixed Issues**: FocusTimer and TasksPage no longer display in sidebar
6. **Authentication**: Added sign-in/sign-out with onboarding flow
7. **Quick Notes**: New feature with auto-save and rich text editing
8. **Clipboard History**: New feature with automatic monitoring

## Usage

### First Launch
1. Sign up with email and password
2. Complete the onboarding tour
3. Start using the app

### Focus Sessions
1. Navigate to Focus tab
2. Choose session type (Focus, Short Break, Long Break)
3. Click Start to begin timer
4. Timer automatically tracks completed sessions

### Task Management
1. Navigate to Tasks tab
2. Click + to create new task
3. Set title, priority, due date, and notes
4. Click task to view details or mark complete

### Quick Notes
1. Navigate to Quick Notes tab
2. Click + to create new note
3. Use toolbar for rich text formatting
4. Notes auto-save on every change

### Clipboard History
1. Navigate to Clipboard tab
2. Monitoring starts automatically
3. Copy text to add to history
4. Click items to copy back to clipboard
5. Star items to mark as favorites

## Keyboard Shortcuts

- `⌘N` - New Task/Note (context-dependent)
- `⌘F` - Search
- `⌘,` - Settings (from profile menu)
- `⌘Q` - Quit

## Customization

### Appearance
- Access from profile menu → App Settings
- Choose Light, Dark, or System appearance

### Focus Timer
- Access from profile menu → App Settings
- Customize focus duration, break duration, and sessions before long break

### Notifications
- Access from profile menu → App Settings
- Enable/disable notifications and sounds

## Development

### Building
```bash
xcodebuild -scheme OneFocus -configuration Release
```

### Testing
- Unit tests: `⌘U`
- UI tests: `⌘U` (with UI test target selected)

## Architecture

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **UserDefaults**: Local data persistence
- **NSPasteboard**: Clipboard monitoring (macOS)
- **MVVM Pattern**: Clean separation of concerns

## Notes

- All code is pure Swift and SwiftUI (no UIKit)
- Follows Apple Human Interface Guidelines
- Designed for macOS 13+ with native components
- Auto-saves all user data locally

## License

Proprietary - All rights reserved

## Version

1.0.0 - Initial Release

---

Built by Noah McClung for macOS
