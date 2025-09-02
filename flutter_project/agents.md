# Instructions for AI agents working on the Flutter project

## GENERAL
- Only make the requested changes. You can make suggestions, but no changes to the code outside the scope of the requested changes.
- If any instruction is ambiguous, clarify before continuing.
- ALWAYS read the whole file, DO NOT read files piece by piece.
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

## PYTHON SCRIPTS
- When running any Python scripts, always use `uv run` prefix (e.g., `uv run copy_source_to_flutter.py`)
- The main script `copy_source_to_flutter.py` copies markdown content from the main project to the Flutter assets directory
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
- Lesson content is stored as markdown files in assets/documents/
- Audio files can be played from remote URLs or local storage
- Images are stored in assets/documents/assets/images/
- Content synchronization with the remote repository is handled by ContentSyncService

## ERROR HANDLING
- All screens should display appropriate loading indicators during async operations
- Error states should be clearly communicated to the user with retry options when possible
- Network errors should be handled gracefully, especially for audio streaming