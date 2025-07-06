// This is the service worker with the combined offline experience (Offline page + Offline copy of pages)

// Add this below content to your HTML page, or add the js file to your page at the very top to register service worker

// PWA VALIDATION LOGS - Added for debugging
console.log("[PWA Debug] Service worker registration script loaded");
console.log("[PWA Debug] Current location:", window.location);
console.log("[PWA Debug] Base URL:", document.baseURI);
console.log("[PWA Debug] Manifest link found:", document.querySelector('link[rel="manifest"]'));
console.log("[PWA Debug] Service Worker support:", 'serviceWorker' in navigator);

// Check compatibility for the browser we're running this in
if ("serviceWorker" in navigator) {
  if (navigator.serviceWorker.controller) {
    console.log("[PWA Builder] active service worker found, no need to register");
  } else {
    // Detect GitHub Pages deployment
    const isGitHubPages = window.location.pathname.includes('/meditation-course-on-the-six-senses/');
    const scope = isGitHubPages ? '/meditation-course-on-the-six-senses/' : './';
    
    console.log("[PWA Debug] Registering service worker with scope:", scope);
    
    // Register the service worker
    navigator.serviceWorker
      .register("pwabuilder-sw.js", {
        scope: scope
      })
      .then(function (reg) {
        console.log("[PWA Builder] Service worker has been registered for scope: " + reg.scope);
      })
      .catch(function (error) {
        console.error("[PWA Builder] Service worker registration failed:", error);
      });
  }
} else {
  console.error("[PWA Debug] Service Worker not supported in this browser");
}