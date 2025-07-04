// Service Worker for PWA functionality
const CACHE_NAME = 'six-senses-pwa-v1';
const ASSETS_TO_CACHE = [
  '/meditation-course-on-the-six-senses/',
  '/meditation-course-on-the-six-senses/index.html',
  '/meditation-course-on-the-six-senses/manifest.webmanifest',
  '/meditation-course-on-the-six-senses/assets/css/custom.css',
  '/meditation-course-on-the-six-senses/assets/images/icon-192.png',
  '/meditation-course-on-the-six-senses/assets/images/icon-512.png',
  '/meditation-course-on-the-six-senses/assets/images/six-senses.svg',
  '/meditation-course-on-the-six-senses/js/custom.js',
  '/meditation-course-on-the-six-senses/service-worker.js'
];

// Install event - cache assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Cache opened');
        return cache.addAll(ASSETS_TO_CACHE);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Fetch event - serve from cache, fall back to network
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached response if found
        if (response) {
          return response;
        }
        // Clone the request for the fetch
        const fetchRequest = event.request.clone();
        // Make network request
        return fetch(fetchRequest)
          .then((response) => {
            // Check if valid response
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            // Clone the response
            const responseToCache = response.clone();
            // Cache the response
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseToCache);
              });
            return response;
          })
          .catch(() => {
            // Return offline fallback if fetch fails
            return new Response('Offline content not available');
          });
      })
  );
});
