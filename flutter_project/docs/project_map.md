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
├── documents/                  # Markdown content (copied from source)
│   ├── *.md                    # Lesson content files
│   └── assets/                 # Audio and image assets
│       ├── audio/              # Audio files
│       └── images/             # Image files
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
- Documents are stored in `assets/documents/` during development
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