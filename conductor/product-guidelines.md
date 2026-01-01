# Product Guidelines: Meditation Course on the Six Senses

## Content & Editorial Standards
- **Precise & Accessible:** Maintain the established structure: human-readable prose paired with technical Pāḷi quotes and accurate translations.
- **Chapter Components:** Every course page must include:
    1. Human-readable instructional text.
    2. Pāḷi quotes and translations.
    3. Guided meditation MP3 with accompanying transcript.
    4. Questions and answers section.
    5. Further reading links.
    6. Make corrections link for community feedback.
- **Single Source of Truth:** All content must originate from the Markdown files in the `source/` directory to ensure consistency across Web, App, and Ebook formats.

## User Experience (UX) & Interaction
- **Distraction-Free Design:** The UI should be unobtrusive, prioritizing the reading and listening experience.
- **Intuitive Navigation:**
    - Support linear progression via "Next" and "Back" buttons (Web) or swiping gestures (Mobile).
    - Provide a global menu/Table of Contents for jumping to any section.
- **State Persistence:** The application must always remember and restore the user's last reading position.
- **Search & Reference:** Enable quick access to specific Dhamma concepts and sections.

## Visual Design & Accessibility
- **Typography First:** Prioritize legibility with high-contrast text, generous line-height, and responsive font sizes suitable for all ages.
- **Visual Hierarchy:** Use clear styling (e.g., blockquotes, italics, spacing) to distinguish between instructional prose, Pāḷi citations, and meditation guides.
- **Responsive Layout:** The design must adapt seamlessly to mobile, tablet, and desktop screens.

## Technical Quality & Performance
- **Offline Reliability:**
    - The mobile application must verify that all bundled media (MP3s) are present and functional without internet access.
    - Gracefully hide or identify internet-dependent features (like external links) when offline.
- **Asset Optimization:** Balance media quality with file size to ensure smooth performance on older Android devices, avoiding unnecessary battery drain.
- **Automated Validation:** The build pipeline should verify link integrity and the presence of mandatory content blocks (MP3s, Pāḷi quotes) in every chapter.
