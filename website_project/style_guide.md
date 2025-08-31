# Website Style and Feature Guide

This document outlines the plan for implementing the new website design and features.

## 1. Layout

-   **Desktop**: A responsive three-column layout will be implemented using CSS Flexbox or Grid.
    -   **Left Sidebar**: Will contain the main index (list of all pages).
    -   **Main Content**: The primary content of the page.
    -   **Right Sidebar**: Will contain the on-page table of contents (subheadings).
-   **Mobile**: On screens below a certain width (e.g., 768px), the sidebars will be hidden, and the layout will switch to a single column for readability.

## 2. Header

-   **Structure**: The header will be a flex container.
-   **Content**:
    -   **Logo**: The `six-senses.svg` will be used.
    -   **Title**: "Meditation Course on the Six Senses".
    -   **Toggles**: Placeholders for Light/Dark mode and Online/Offline status toggles will be added.
-   **Behavior**: The header will hide on scroll-down and reappear on scroll-up. This will be implemented with JavaScript.

## 3. Footer Navigation

-   **Structure**: The footer will contain two links, one for the previous page and one for the next.
-   **Functionality**: The `build.py` script will be updated to pass `prev_page` and `next_page` objects to the Jinja2 template for each page.

## 4. Sidebars

-   **Left (Index)**: The `build.py` script will pass a list of all pages to the template, which will render this sidebar.
-   **Right (On-Page ToC)**: A JavaScript function will run on page load, find all `h2` and `h3` tags in the main content, and dynamically build the Table of Contents.

## 5. Styling (CSS)

-   **Color Scheme**: CSS variables will be used to define the color palette for easy theming.
    -   `--background-color`
    -   `--text-color`
    -   `--primary-color` (for links and accents)
    -   `--block-background-color` (for quotes and transcripts)
-   **Light/Dark Mode**: A `dark-mode` class on the `<body>` element will switch the values of the CSS variables. A JS toggle will control this and save the preference in `localStorage`.
-   **Quotes**: `<blockquote>` elements will be styled with a distinct background color, padding, and a border.
-   **Transcripts**: The `<details>` and `<summary>` elements will be styled to match the reference design, making them look like distinct, clickable components.

## 6. JavaScript (`main.js`)

A new file at `static/js/main.js` will be created to handle:

-   Hiding/showing the header on scroll.
-   Toggling light and dark mode.
-   Generating the on-page Table of Contents for the right sidebar.
