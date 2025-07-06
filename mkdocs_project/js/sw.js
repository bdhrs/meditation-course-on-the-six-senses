var GHPATH = '/meditation-course-on-the-six-senses';
var CACHE_NAME = 'six-senses-cache-v1';
var FILES_TO_CACHE = [];

self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function (cache) {
        console.log('Opened cache');
        return cache.addAll(FILES_TO_CACHE);
      })
  );
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheNames) {
      return Promise.all(
        cacheNames.map(function (cacheName) {
          if (CACHE_NAME !== cacheName) {
            console.log('Clearing old cache ', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

self.addEventListener('fetch', function (event) {
  if (event.request.method !== 'GET') return;

  var url = new URL(event.request.url);

  // GitHub Pages URL check
  if (!url.pathname.startsWith(GHPATH)) {
    return fetch(event.request);
  }

  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        // Cache hit - return response
        if (response) {
          return response;
        }

        // Not in cache - return fetch
        return fetch(event.request).then(
          function (response) {
            // Check if we received a valid response
            if(!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // IMPORTANT: Clone the response. A response is a stream
            // and because we want the response to both be used by the cache and returned to the app
            // we need to clone it.
            var responseToCache = response.clone();

            caches.open(CACHE_NAME)
              .then(function (cache) {
                cache.put(event.request, responseToCache);
              });

            return response;
          }
        );
      })
    );
});

fetch('files-to-cache.json')
  .then(response => response.json())
  .then(files => {
    FILES_TO_CACHE = files.map(file => GHPATH + '/' + file);
    console.log('Files to cache:', FILES_TO_CACHE);
  });