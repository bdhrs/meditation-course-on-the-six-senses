# Instructions for AI agents working on the Flutter project

## GENERAL
- **ONLY MAKE THE REQUESTED CHANGES**. You can make suggestions, but no changes to the code outside the scope of the requested changes.
- If any instruction is ambiguous, **clarify before continuing**.
- **ALWAYS READ THE WHOLE FILE**, DO NOT read files piece by piece.
- Start every single API call with "Hopa!" to let me know you have understood. 
- Follow all instructions explicitly.

## PROJECT ORIENTATION
- Read flutter_project/project_map.md to understand the file structure and functionality of the flutter_project
- The project is a meditation course app that displays lessons in markdown format with audio playback capabilities
- The app supports both online streaming and offline playback of audio files
- Themes are managed through the Provider package with light and dark mode support

## PROJECT_MAP.MD
- Read flutter_project/project_map.md to understand the file structure of the flutter_project
- After making any changes to any file, ALWAYS UPDATE flutter_project/project_map.md
- This helps future agents to understand the project in detail very quickly.

## FLUTTER DEVELOPMENT
- Use `flutter pub get` to install dependencies
- Use `flutter run` to run the app
- Use `flutter test` to run tests
- Always run `flutter analyze` before finishing work to catch any errors or warnings

## PYTHON SCRIPTS
- When running any Python scripts, always use `uv run` prefix (e.g., `uv run copy_assets.py`)
- The main script `copy_assets.py` copies markdown content from the main project to the Flutter assets directory
- Always run this script after updating lesson content to ensure the Flutter app has the latest content

## UPON COMPLETION
- After the user expresses satisfaction with the changes:
  1. Update this document if needed
  2. Provide a git commit message, simple and lowercase. e.g. fix: updated audio player widget
  3. DO NOT commit!

## DART/FLUTTER SPECIFIC
- Follow Flutter best practices and style guide
- Use provider package for state management as specified in the project plan
- Use the existing dependencies in pubspec.yaml
- Write clean, well-documented code
- Follow the project structure already established
- Use StatefulWidget only when necessary for managing state
- Prefer const constructors and widgets for better performance
- Use FutureBuilder for handling asynchronous data loading
- Handle errors gracefully with appropriate UI feedback

## FILE PATHS
- All file paths in Dart code should use forward slashes (/) for cross-platform compatibility
- When referencing assets, use the correct asset paths as defined in pubspec.yaml
- Audio files can be accessed either remotely or locally:
  - Remote: https://github.com/bdhrs/meditation-course-on-the-six-senses/releases/download/audio-assets/
  - Local: Application documents directory under /audio/

## PLAN AND DOCUMENTATION
- Keep flutter_app_plan.md updated as you complete tasks
- Always update project_map.md when making changes to the project structure
- Update agents.md if new instructions or best practices are discovered

## CUSTOM MARKDOWN SYNTAX
- The app uses custom markdown syntax for special features:
  - `%%...%%` for meditation instruction transcripts (renders as expandable sections)
  - `![[file.mp3]]` for audio files (renders as audio player widgets)
  - `[[Link Title]]` or `[[target|Display Text]]` for internal navigation between lessons

## STATE MANAGEMENT
- Theme state is managed through ThemeProvider using the Provider package
- Audio player state is managed within the AudioPlayerWidget using audioplayers package
- Lesson content is loaded asynchronously using FutureBuilder in TableOfContentsScreen

## ASSETS AND CONTENT
- Lesson content is stored as markdown files in assets/markdown/
- Audio files can be played from remote URLs or local storage
- Images are stored in assets/images/ (PNG format preferred)
- Content synchronization with the remote repository is handled by ContentSyncService

## ERROR HANDLING
- All screens should display appropriate loading indicators during async operations
- Error states should be clearly communicated to the user with retry options when possible
- Network errors should be handled gracefully, especially for audio streaming

## NEW SCREENS
- When adding new screens, follow the existing pattern of creating stateless widgets where possible
- Use the existing theme provider for consistent styling
- Add navigation routes in main.dart
- Update project_map.md with details about the new screen


# Flutter Project Map

This document provides an overview of the file structure and key components of the Six Senses Flutter application, including detailed information about each file and its functions.

## Project Structure

```
lib/
├── main.dart                    # Entry point of the application
├── models/
│   └── lesson.dart             # Data model for lessons
├── services/
│   ├── content_service.dart    # Processes markdown content
│   ├── download_service.dart   # Handles audio file downloads
│   └── content_sync_service.dart # Manages content synchronization
├── providers/
│   └── theme_provider.dart     # Manages theme state
├── screens/
│   ├── table_of_contents_screen.dart  # Main screen with lesson list
│   ├── lesson_screen.dart      # Displays individual lessons
│   ├── download_manager_screen.dart   # Manages audio downloads
│   ├── settings_screen.dart    # Application settings
│   └── landing_page_screen.dart       # Landing page with course introduction
├── widgets/
│   └── audio_player_widget.dart # Custom audio player component
├── theme/
│   └── app_theme.dart          # Application theme definitions
assets/
├── markdown/                   # Markdown content (copied from source)
│   └── *.md                    # Lesson content files
├── images/                     # Image assets
├── audio/                      # Audio files
```

## Detailed File Information

### Main Application
**File: `lib/main.dart`**
- **Purpose**: Entry point of the application that initializes the app and sets up routing
- **Key Functions**:
  - `main()`: Initializes the app with ThemeProvider for state management
  - `MyApp`: Root widget that configures MaterialApp with theme support
  - `TableOfContentsScreenWrapper`: Stateful widget that manages navigation between table of contents and lesson screens
  - `_navigateToLesson()`: Navigates to a specific lesson by Lesson object
  - `_navigateToLessonBySlug()`: Navigates to a lesson by its slug identifier

### Models
**File: `lib/models/lesson.dart`**
- **Purpose**: Data model representing a single lesson with all its properties
- **Key Functions**:
  - `Lesson`: Constructor that creates a lesson with title, slug, content, audio files, and navigation links
  - `copyWith()`: Creates a copy of the lesson with optional updated properties
  - `fromJson()`: Factory constructor that creates a Lesson from a JSON map
  - `toJson()`: Converts a Lesson instance to a JSON-compatible map

### Services
**File: `lib/services/content_service.dart`**
- **Purpose**: Processes markdown files from assets and converts them into Lesson objects
- **Key Functions**:
  - `loadLessons()`: Reads all markdown files from assets and creates Lesson objects
  - `_getTitleFromFileName()`: Extracts and formats a title from a file name
  - `_generateSlug()`: Creates a URL-friendly slug from a file name
  - `_processMarkdownContent()`: Processes markdown content with custom syntax conversions
  - `_convertMeditationInstructions()`: Converts `%%...%%` syntax to transcript placeholders
  - `_convertAudioLinks()`: Converts `![[file.mp3]]` syntax to audio placeholders
  - `_convertWikiLinks()`: Converts `[[Link Title]]` syntax to navigation placeholders
  - `_extractAudioFileNames()`: Extracts all unique audio file names from content

**File: `lib/services/download_service.dart`**
- **Purpose**: Manages downloading, checking, and deleting audio files for offline use
- **Key Functions**:
  - `getAllAudioFiles()`: Gets a list of all unique audio files from all lessons
  - `isAudioFileDownloaded()`: Checks if a specific audio file exists locally
  - `downloadAudioFile()`: Downloads a single audio file with progress tracking
  - `downloadAllAudioFiles()`: Downloads all audio files with overall progress tracking
  - `deleteAllAudioFiles()`: Removes all downloaded audio files
  - `getLocalFilePath()`: Gets the local file path for a downloaded audio file

**File: `lib/services/content_sync_service.dart`**
- **Purpose**: Manages synchronization of content from the remote GitHub repository
- **Key Functions**:
  - `getLocalDocumentsPath()`: Gets the path to the local documents directory
  - `hasLocalContent()`: Checks if local content exists
  - `getLastUpdated()`: Gets the last updated timestamp of local content
  - `getLatestCommitInfo()`: Fetches the latest commit information from GitHub
  - `isUpdateAvailable()`: Checks if an update is available by comparing timestamps
  - `downloadAndExtractContent()`: Downloads and extracts the repository zip file
  - `syncContent()`: Syncs content with the remote repository if updates are available

### Providers
**File: `lib/providers/theme_provider.dart`**
- **Purpose**: Manages application theme state (light/dark mode) using Provider pattern
- **Key Functions**:
  - `setThemeMode()`: Sets the theme mode (light, dark, or system)
  - `toggleTheme()`: Cycles through theme modes (light → dark → system → light)
  - `isDarkMode`: Getter that determines if dark mode should be used

### Screens
**File: `lib/screens/table_of_contents_screen.dart`**
- **Purpose**: Main screen showing the list of all lessons with loading and error states
- **Key Functions**:
  - `TableOfContentsScreen`: Stateful widget that displays the lesson list
  - `_lessonsFuture`: Future that holds the list of lessons from ContentService
  - `initState()`: Loads lessons when the screen is initialized
  - `build()`: Constructs the UI with a FutureBuilder for async loading

**File: `lib/screens/lesson_screen.dart`**
- **Purpose**: Displays the content of a single lesson with custom markdown rendering and navigation controls
- **Key Functions**:
  - `LessonScreen`: Stateless widget that displays a lesson's content
  - `_buildMarkdownContent()`: Parses and renders markdown content with custom syntax
  - `_buildParagraph()`: Renders a paragraph of text
  - `_buildHeading()`: Renders a heading with appropriate styling
  - `_buildAudioWidget()`: Renders an audio player widget for audio files
  - `_buildTranscriptWidget()`: Renders an expandable transcript widget
  - `_buildLinkWidget()`: Renders a navigable link to another lesson
- **UI Improvements**:
  - Updated drawer styling to match website design with custom header and list items
  - Added proper border separators and padding for list items
  - Implemented theme-aware colors for both light and dark modes
  - Enhanced selected state styling for current lesson
  - Improved "Home" button styling in drawer

**File: `lib/screens/download_manager_screen.dart`**
- **Purpose**: UI for managing audio file downloads with progress tracking and error handling
- **Key Functions**:
  - `DownloadManagerScreen`: Stateful widget for managing audio downloads
  - `_loadAudioFiles()`: Loads the list of audio files and checks download status
  - `_downloadAllAudio()`: Downloads all audio files with progress tracking
  - `_deleteAllAudio()`: Deletes all downloaded audio files
  - `build()`: Constructs the UI with download controls and file list
  - `_getStatusText()`: Returns a human-readable status for a download
  - `_getStatusIcon()`: Returns an appropriate icon for a download status

**File: `lib/screens/settings_screen.dart`**
- **Purpose**: Application settings screen including theme toggle and download management
- **Key Functions**:
  - `SettingsScreen`: Stateful widget for application settings
  - `build()`: Constructs the UI with theme toggle and download manager link

**File: `lib/screens/landing_page_screen.dart`**
- **Purpose**: Landing page that shows the course title and subtitle with a starting point
- **Key Functions**:
  - `LandingPageScreen`: Stateless widget that displays the course title and subtitle
  - `build()`: Constructs the UI with course title, subtitle, and a "Get Started" button

### Widgets
**File: `lib/widgets/audio_player_widget.dart`**
- **Purpose**: Custom audio player with play/pause controls, progress tracking, and offline support
- **Key Functions**:
  - `AudioPlayerWidget`: Stateful widget for playing audio files
  - `initState()`: Initializes the audio player and checks download status
  - `_checkDownloadStatus()`: Checks if the audio file is available offline
  - `_play()`: Plays or pauses the audio file (from local or remote source)
  - `_stop()`: Stops the audio playback
  - `_formatDuration()`: Formats a Duration into MM:SS format
  - `build()`: Constructs the UI with controls and progress tracking

### Theme
**File: `lib/theme/app_theme.dart`**
- **Purpose**: Defines light and dark theme configurations that match the website styling
- **Key Functions**:
  - `lightTheme`: Getter that returns the light theme configuration
  - `darkTheme`: Getter that returns the dark theme configuration
  - Contains color definitions that match the website CSS

## Asset Structure
- Documents are stored in `assets/markdown/` during development
- Images are stored in `assets/images/`
- Audio files are stored in `assets/audio/`
- In production, content would be downloaded to device storage
- Audio files can be played from remote URLs or local storage
- Theme colors and styling match the website project CSS

## Features
- Parse and display markdown content with custom syntax
- Play audio files from remote URLs or local storage
- Download all audio files for offline use
- Navigate between lessons with previous/next buttons, including navigation back to the landing page
- Light and dark mode themes matching the website
- Proper error handling and loading indicators
- Responsive design for different screen sizes