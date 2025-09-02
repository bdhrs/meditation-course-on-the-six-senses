# Offline Download Functionality Implementation

## Overview

This document describes the audio file download functionality implemented for the Six Senses Meditation Course offline mode feature. The system provides two-level progress tracking, pause/resume capabilities, and retry mechanisms for downloading audio files from GitHub Releases.

## Files Created

### 1. Core Download Manager (`static/js/offline-manager.js`)
- **Purpose**: Handles the actual download logic and progress tracking
- **Features**:
  - Two-level progress tracking (overall + current file)
  - Pause/resume functionality using AbortController
  - Retry mechanism with exponential backoff (3 retries max)
  - File size estimation via HEAD requests
  - Event-based callbacks for UI updates

### 2. UI Components (`static/js/offline-ui.js` and `static/css/offline-mode.css`)
- **Purpose**: Provides user interface for download management
- **Features**:
  - Modal overlay with progress bars
  - Real-time progress updates
  - Control buttons (start, pause/resume, cancel)
  - Status messages and error handling
  - Responsive design matching the existing theme
  - Green color scheme integration with CSS variables

## Key Features Implemented

### Two-Level Progress Tracking
- **Overall Progress**: Files downloaded/total files + bytes downloaded/total bytes
- **Current File Progress**: Bytes downloaded/total bytes for the active download
- **Visual Representation**: Dual progress bars with percentage and file size displays

### Pause/Resume Functionality
- Uses `AbortController` to pause downloads
- Maintains download state to allow resuming from where it left off
- Visual indicators for paused state

### Retry Mechanism
- Automatic retry on network failures (up to 3 attempts)
- Exponential backoff between retries (1s, 2s, 3s)
- Clear error reporting for failed downloads

### GitHub Releases Integration
- Downloads from: `https://github.com/bdhrs/meditation-course-on-the-six-senses/releases/download/audio-assets/`
- Uses fetch API with proper error handling
- HEAD requests for file size estimation

## Integration with Build System

The offline download functionality integrates with the existing build system through:

### 1. Audio Files List Generation
The build system (`build.py`) already generates `audio-files.json` which contains the list of all audio files needed for offline mode. This file is used by the download manager to know which files to download.

### 2. CSS Integration
The offline mode CSS uses the same CSS variables as the main theme:
- `--primary-color`: Green progress bars
- `--background-color`: Modal background
- `--text-color`: Text colors
- `--border-color`: Borders and separators

### 3. JavaScript Integration
The offline manager can be initialized with the audio files list from `audio-files.json`:

```javascript
// Example usage
fetch('audio-files.json')
    .then(response => response.json())
    .then(audioFiles => {
        const offlineUI = new OfflineUI();
        offlineUI.initialize();
        offlineUI.setup(audioFiles);
        
        // Show UI when offline mode is requested
        offlineUI.show();
    });
```

## Usage Example

```javascript
// Basic usage
const manager = new OfflineManager();
manager.initialize(audioFilesList);

manager.setCallbacks({
    onProgress: (progress) => {
        console.log('Progress:', progress);
    },
    onComplete: () => {
        console.log('Download complete!');
    },
    onError: (error) => {
        console.error('Download error:', error);
    }
});

// Start download
await manager.startDownload();

// Pause/resume
manager.pauseDownload();
manager.resumeDownload();

// Cancel
manager.cancelDownload();
```

## Testing

A test page (`test-download.html`) is provided to verify functionality:
- Tests download from GitHub Releases
- Shows both basic console output and full UI
- Uses smaller audio files for quick testing

## Browser Compatibility

- **Chrome/Edge**: Full support (fetch, AbortController, CSS Grid/Flexbox)
- **Firefox**: Full support
- **Safari**: Full support (iOS 12+)
- **Mobile**: Responsive design works on all screen sizes

## Performance Considerations

- **Memory Usage**: Files are processed as streams to avoid large memory usage
- **Network**: Sequential downloads to avoid overwhelming connections
- **Storage**: Currently downloads to memory (Blob objects) - will integrate with IndexedDB in next phase

## Next Steps for Full Offline Mode

1. **Storage Integration**: Add IndexedDB or Cache API for persistent storage
2. **Asset Management**: Create URL rewriting system for offline/online mode switching
3. **Update Checking**: Implement version checking and differential updates
4. **Service Worker**: Enhance service worker to handle offline asset serving
5. **Error Recovery**: Add more robust error handling and recovery mechanisms

## File Sizes and Download Times

- Total audio files: ~800MB (37 files)
- Estimated download time: 20-60 minutes on average broadband
- Progress tracking helps users understand download status

## Error Handling

The system handles:
- Network failures (automatic retry)
- HTTP errors (404, 500, etc.)
- User-initiated pauses and cancellations
- Browser compatibility issues (fallbacks)

This implementation provides a solid foundation for the offline mode feature with professional-grade download management and user experience.