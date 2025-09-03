# Website to Flutter App Reference Document

This document serves as a comprehensive reference for implementing website features and styles in the Flutter app. It captures all the design elements, components, and functionality from the website project that should be applied to the Flutter app.

## 1. Overall Layout Structure

### Website Structure
- **Desktop**: Three-column layout using CSS Flexbox
 - Left Sidebar: Main index (list of all pages)
  - Main Content: Primary content of the page
  - Right Sidebar: On-page table of contents (subheadings)
- **Mobile**: Single column layout for readability on small screens
  - Sidebars hidden on screens below 768px width

### Flutter Implementation Notes
- Current Flutter app uses a drawer for navigation instead of a persistent sidebar
- Need to implement a responsive layout that adapts to screen size
- Consider using Flutter's LayoutBuilder or MediaQuery for responsive design

## 2. Color Scheme and Themes

### Website Colors
**Light Mode:**
- Background: #ffffff (--background-color-light)
- Sidebar Background: #f8f8f8 (--sidebar-bg-light)
- Text: #212121 (--text-color-light)
- Primary: #366348 (--primary-color-light)
- Block Background: #f0f0f0 (--block-bg-light)
- Border: #e0e0 (--border-color-light)
- Header/Footer Background: #f5f5f5 (--header-footer-bg-light)
- Scrollbar Background: #f5f5f5 (--scrollbar-bg-light)
- Scrollbar Thumb: #366348 (--scrollbar-thumb-light)

**Dark Mode:**
- Background: #121614 (--background-color-dark)
- Sidebar Background: #1a1f1c (--sidebar-bg-dark)
- Text: #e0e0e0 (--text-color-dark)
- Primary: #96c5a9 (--primary-color-dark)
- Block Background: #15271d (--block-bg-dark)
- Border: #264532 (--border-color-dark)
- Header/Footer Background: #0f1c14 (--header-footer-bg-dark)
- Scrollbar Background: #0f1c14 (--scrollbar-bg-dark)
- Scrollbar Thumb: #96c5a9 (--scrollbar-thumb-dark)

### Flutter Implementation
- Colors are already partially implemented in `flutter_project/lib/theme/app_theme.dart`
- Need to ensure all website colors are mapped to Flutter theme
- Current implementation uses Material Design color scheme but should align with website palette

## 3. Header Component

### Website Features
- Flex container with logo, title, and toggle buttons
- Logo: `six-senses.svg`
- Title: "Meditation Course on the Six Senses"
- Toggle buttons for Light/Dark mode and Online/Offline status
- Behavior: Header hides on scroll-down and reappears on scroll-up

### Flutter Implementation
- Current app uses AppBar with menu and settings icons
- Need to add logo and course title to AppBar
- Implement theme toggle functionality (currently exists but needs visual update)
- Consider implementing scroll-hide behavior

## 4. Navigation Sidebars

### Left Sidebar (Course Outline)
- Contains list of all pages/lessons
- Each item has padding and border-bottom separator
- Hover effect changes text color to primary color
- Current lesson is highlighted with primary color and bold text

### Right Sidebar (On-Page Table of Contents)
- Contains subheadings from main content (h2 and h3 tags)
- h3 entries are indented and smaller font size
- Dynamically generated with JavaScript

### Flutter Implementation
- Current app uses Drawer for navigation instead of persistent sidebar
- Lesson list is implemented in Drawer but needs styling improvements
- No on-page table of contents currently exists in Flutter app
- Need to implement responsive sidebar behavior (persistent on desktop, hidden on mobile)

## 5. Main Content Area

### Website Features
- Max width of 960px with padding
- Responsive padding (3rem desktop, 1.5rem tablet, 1rem mobile)
- Content centered horizontally

### Flutter Implementation
- Current app uses SingleChildScrollView with padding
- Need to implement max width constraint and responsive padding

## 6. Typography

### Website Styles
- Font family: "Inter", sans-serif
- Base font size: 16px with 1.6 line height
- Headings:
  - h1: Not specifically styled (used for title page)
  - h2: 1.2em, bold
  - h3: 0.9em (in TOC), normal weight

### Flutter Implementation
- Need to implement Inter font family
- Current textTheme partially matches but needs refinement
- Heading styles need to be implemented in markdown parser

## 7. UI Components

### Links
- Primary color for text (#366348 light, #96c5a9 dark)
- No underline by default
- Underline on hover

### Blockquotes
- Background color matching block-bg variables
- Left border: 5px solid primary color
- Padding: 0 1.5rem
- Margin: 1.5rem 0
- Rounded corners (0.5rem)
- Horizontal scroll for overflow content

### Transcripts
- Uses `<details>` and `<summary>` elements
- Background color matching block-bg variables
- Border: 1px solid border-color
- Rounded corners (0.5rem)
- Padding: 0 2rem
- Summary is bold, primary color
- Content text is smaller (0.9em)
- Horizontal rules are thin and theme-appropriate gray

### Audio Player
- Width: 100% with max-width constraint
- Background color matching block-bg variables
- Rounded corners (0.5rem)
- Padding: 0.75rem 1rem
- Margin: 1.5rem 0
- Subtle shadow
- Custom styled media controls

### Flutter Implementation Notes
- Transcript widget exists but uses ExpansionTile instead of details/summary
- Audio player widget exists but needs visual updates to match website
- Blockquote styling needs to be implemented in markdown parser

## 8. Footer Navigation

### Website Features
- Two buttons: Previous and Next
- Previous button has right border
- Buttons take up equal space
- Disabled buttons have 0.5 opacity
- Text truncates with ellipsis for long titles
- Arrow indicators on both sides

### Flutter Implementation
- Current app uses ElevatedButtons for navigation
- Layout needs to match website design
- Need to implement disabled state styling

## 9. Interactive Features

### Theme Toggle
- Toggles between light and dark mode
- Saves preference in localStorage
- Icon changes between sun (light) and moon (dark)
- Smooth transition animations

### Scroll Behavior
- Header hides on scroll-down, shows on scroll-up
- Header always shows when at bottom of page
- Smooth animations for show/hide

### On-Page Table of Contents
- Dynamically generated from h2/h3 headings
- Clicking links scrolls to corresponding section
- h3 entries are indented

### Menu Toggle
- Shows/hides left sidebar on narrow screens
- Uses hamburger menu icon

## 10. Responsive Design Breakpoints

### Large Screens (>1200px)
- All three columns visible
- No menu toggle needed

### Medium Screens (992px - 1200px)
- Left sidebar hidden by default
- Menu toggle shows left sidebar
- Right sidebar still visible

### Small Screens (768px - 992px)
- Both sidebars hidden
- Menu toggle shows left sidebar
- Main content padding reduced

### Extra Small Screens (<768px)
- All responsive adjustments from small screens
- Additional font size and padding adjustments
- Audio player padding reduced

## 11. Custom Scrollbar Styling

### Website Features
- Width/Height: 12px
- Track background: scrollbar-bg color
- Thumb background: scrollbar-thumb color
- Rounded corners: 6px
- Border: 2px solid scrollbar-bg
- Hover effect: Darkened thumb color
- Also implemented for Firefox with scrollbar-width: thin

### Flutter Implementation
- Current app has basic scrollbar theming
- Need to refine to match website styling

## 12. Markdown Custom Syntax

### Website Implementation
- `%%...%%` for meditation instruction transcripts
- `![[file.mp3]]` for audio files
- `[[Link Title]]` or `[[target|Display Text]]` for internal navigation

### Flutter Implementation
- ContentService converts these to custom syntax:
  - `{{transcript:content}}`
  - `{{audio:filename.mp3}}`
  - `{{link:target|displayText}}`
- LessonScreen parses these custom syntax elements
- Transcript uses ExpansionTile
- Audio uses custom AudioPlayerWidget
- Links use GestureDetector with underline styling

## 13. Title Page Styling

### Website Features
- Centered text with large heading
- Heading: 3em, bold (900), primary color, text shadow
- Subtitle: 1.5em, 500 weight
- Content: Left-aligned with increased line height
- Lists: Centered with left alignment, increased line height

### Responsive Adjustments
- 768px: Heading 2.2em, Subtitle 1.2em
- 480px: Heading 1.8em, Subtitle 1em, reduced padding

### Flutter Implementation
- LandingPageScreen has some title styling but needs refinement
- Need to implement responsive adjustments

## 14. Additional Styling Elements

### Sutta References
- Italic text in primary color

### Tables
- Border-collapse: collapse
- Full width with margin
- Header cells: block-bg background, bold
- Alternating row colors
- Responsive adjustments for small screens

### Error Pages
- Centered content with max width
- Large heading in primary color
- Prominent call-to-action button with hover effect

## 15. JavaScript Functionality to Implement in Flutter

### Header Scroll Behavior
- Detect scroll direction
- Hide/show header with animation
- Always show when at bottom

### Dynamic Table of Contents
- Parse main content for headings
- Generate navigation list
- Implement smooth scrolling

### Theme Toggle
- Toggle between theme modes
- Save preference
- Update UI icons

### Menu Toggle
- Show/hide sidebar on mobile
- Smooth animations

## 16. Icons and Assets

### Website Icons
- menu-icon.svg: Hamburger menu
- six-senses.svg: Logo
- status-icon-offline.svg: Offline status
- status-icon.svg: Online status
- theme-icon-moon.svg: Dark mode
- theme-icon.svg: Light mode

### Flutter Implementation
- Need to add these assets to Flutter project
- Implement proper icon switching for theme toggle

## 17. Performance Considerations

### Website Features
- Custom scrollbar styling
- Transition animations (0.3s for theme, 0.4s cubic-bezier for sidebar)
- Efficient JavaScript for scroll handling (passive event listeners)

### Flutter Implementation
- Use const widgets where possible
- Implement efficient rebuilds with proper state management
- Consider lazy loading for long content lists

## 18. Accessibility Features

### Website Features
- Proper semantic HTML
- ARIA labels for interactive elements
- Sufficient color contrast
- Focus states for keyboard navigation

### Flutter Implementation
- Ensure semantic widget selection
- Implement proper focus traversal
- Maintain color contrast ratios
- Add accessibility labels where needed

## Implementation Priority

1. Core layout and responsive design
2. Color scheme and typography
3. Header and navigation components
4. Main content styling
5. UI components (blockquotes, transcripts, audio player)
6. Footer navigation
7. Interactive features
8. Performance optimizations
9. Accessibility improvements

## Notes for Implementation

- The Flutter app already has many of the core features but needs visual refinement to match the website
- Theme system is partially implemented but needs to align with website color palette
- Custom markdown parsing exists but needs styling updates
- Responsive behavior needs to be implemented to match website breakpoints
- Many UI components need visual updates to match website styling

## Detailed Implementation Requirements

### Core Layout and Responsive Design
1. **Responsive Layout Framework**
   - Create responsive layout widgets that adapt to screen sizes
   - Implement breakpoints matching website (1200px, 992px, 768px, 480px)
   - Set up LayoutBuilder or similar mechanism for responsive behavior

2. **Three-Column Layout**
   - Implement persistent sidebars for desktop view
   - Create responsive behavior for mobile (sidebars hidden by default)
   - Add smooth animations for sidebar show/hide transitions

### Color Scheme and Typography
1. **Color Scheme Alignment**
   - Update `flutter_project/lib/theme/app_theme.dart` to match exact website color values
   - Ensure both light and dark themes match website CSS variables
   - Test color contrast ratios for accessibility

2. **Typography System**
   - Add Inter font to Flutter project assets
   - Update textTheme in AppTheme to match website specifications
   - Implement proper heading styles (h1, h2, h3) in markdown parser

### Header and Navigation Components
1. **Header Component**
   - Add logo asset (`six-senses.svg`) to Flutter project
   - Update AppBar to include logo and full course title
   - Implement theme toggle with proper icons (sun/moon)
   - Add scroll-hide behavior using NotificationListener

2. **Sidebar Navigation System**
   - Replace Drawer with persistent sidebar for desktop
   - Implement responsive sidebar behavior (persistent on desktop, hidden on mobile)
   - Style lesson list to match website (padding, separators, hover effects)
   - Add current lesson highlighting

3. **Main Content Area**
   - Implement max-width constraint (960px)
   - Add responsive padding adjustments
   - Center content horizontally

### UI Components
1. **Enhanced Markdown Parser**
   - Update `_buildParagraph` method to handle blockquotes with proper styling
   - Implement heading styles that match website specifications
   - Add support for sutta reference styling

2. **Audio Player Widget**
   - Update visual design to match website styling
   - Implement proper width constraints and rounded corners
   - Add subtle shadow effect
   - Improve slider and control styling

3. **Transcript Component**
   - Update ExpansionTile to better match website details/summary styling
   - Implement proper indentation for nested content
   - Add horizontal rules styling

4. **Footer Navigation**
   - Redesign previous/next buttons to match website styling
   - Implement proper disabled state styling
   - Add text truncation for long titles
   - Include arrow indicators on both sides

5. **On-Page Table of Contents**
   - Implement dynamic TOC generation from content headings
   - Create right sidebar for TOC on desktop
   - Add smooth scrolling behavior
   - Style h2/h3 entries with proper indentation

6. **Menu Toggle**
   - Implement hamburger menu for mobile navigation
   - Add smooth animations for sidebar show/hide
   - Include proper icon assets

### Interactive Features
1. **Theme Toggle**
   - Enhance existing theme toggle with proper icons
   - Implement smooth transition animations
   - Ensure icon changes between sun (light) and moon (dark)

2. **Header Scroll Behavior**
   - Implement scroll detection to hide/show header
   - Add smooth animations for show/hide transitions
   - Ensure header always shows when at bottom of page

### Polish and Optimization
1. **Scrollbar Styling**
   - Implement custom scrollbar theming to match website
   - Add hover effects and proper sizing

2. **Additional UI Components**
   - Implement table styling
   - Add error page styling
   - Implement form components if needed

3. **Performance Optimizations**
   - Add const widgets where possible
   - Implement lazy loading for long content
   - Optimize rebuilds with proper state management

4. **Accessibility Improvements**
   - Add semantic labels to interactive elements
   - Ensure proper focus traversal
   - Verify color contrast ratios
   - Add ARIA-equivalent functionality

### Key Considerations

1. **Asset Management**
   - Add all required SVG icons to Flutter assets
   - Implement proper asset loading and caching
   - Consider vector graphics for scalability

2. **State Management**
   - Leverage existing Provider setup for theme management
   - Consider additional state management for complex UI components
   - Ensure efficient rebuilds to maintain performance

3. **Testing Strategy**
   - Test on multiple device sizes and orientations
   - Verify both light and dark mode appearances
   - Check accessibility with screen readers
   - Validate performance on lower-end devices

4. **Code Organization**
   - Create reusable widgets for consistent styling
   - Maintain clear separation between layout and content
   - Document custom components for future maintenance

This implementation approach ensures a systematic transformation of the Flutter app to match the website design while maintaining the existing functionality.