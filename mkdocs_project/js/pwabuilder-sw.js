// This is the service worker with the combined offline experience (Offline page + Offline copy of pages)

const CACHE = "pwabuilder-offline-page";

// TODO: replace the following with the correct offline fallback page i.e.: const offlineFallbackPage = "offline.html";
const offlineFallbackPage = "offline.html";

// GitHub Pages base path detection
const isGitHubPages = self.location.pathname.includes('/meditation-course-on-the-six-senses/');
const basePath = isGitHubPages ? '/meditation-course-on-the-six-senses/' : '/';

console.log("[PWA Debug] Service Worker - Base path detected:", basePath);
console.log("[PWA Debug] Service Worker - Is GitHub Pages:", isGitHubPages);

// Install stage sets up the offline page in the cache and opens a new cache
self.addEventListener("install", function (event) {
  console.log("[PWA Builder] Install Event processing");

  event.waitUntil(
    caches.open(CACHE).then(function (cache) {
      console.log("[PWA Builder] Cached offline page during install");

      if (offlineFallbackPage === "ToDo-replace-this-name.html") {
        return cache.add(new Response("TODO: Update the value of the offlineFallbackPage constant in the serviceworker."));
      }

      // Use absolute path for GitHub Pages
      const offlinePageUrl = isGitHubPages ? basePath + offlineFallbackPage : offlineFallbackPage;
      console.log("[PWA Builder] Caching offline page:", offlinePageUrl);
      return cache.add(offlinePageUrl);
    })
  );
});

// If any fetch fails, it will look for the request in the cache and serve it from there first
self.addEventListener("fetch", function (event) {
  if (event.request.method !== "GET" || event.request.url.startsWith('chrome-extension')) return;

  // Skip caching for external resources
  const url = new URL(event.request.url);
  const isOwnDomain = url.origin === self.location.origin;
  const isWithinScope = isGitHubPages ? url.pathname.startsWith(basePath) : true;
  
  if (!isOwnDomain || !isWithinScope) {
    return fetch(event.request);
  }

  event.respondWith(
    fetch(event.request)
      .then(function (response) {
        console.log("[PWA Builder] add page to offline cache: " + response.url);

        // If request was success, add or update it in the cache
        if (response.status === 200) {
          event.waitUntil(updateCache(event.request, response.clone()));
        }

        return response;
      })
      .catch(function (error) {
        console.log("[PWA Builder] Network request Failed. Serving content from cache: " + error);
        return fromCache(event.request);
      })
  );
});

function fromCache(request) {
  // Check to see if you have it in the cache
  // Return response
  // If not in the cache, then return the offline page
  return caches.open(CACHE).then(function (cache) {
    return cache.match(request).then(function (matching) {
      if (!matching || matching.status === 404) {
        // The following validates that the request was for a navigation to a new document
        if (request.destination !== "document" || request.mode !== "navigate") {
          return new Response();
        }

        // Use the same offline page URL as in install
        const offlinePageUrl = isGitHubPages ? basePath + offlineFallbackPage : offlineFallbackPage;
        console.log("[PWA Builder] Serving offline page:", offlinePageUrl);
        return cache.match(offlinePageUrl);
      }

      return matching;
    });
  });
}

function updateCache(request, response) {
  return caches.open(CACHE).then(function (cache) {
    return cache.put(request, response);
  });
}