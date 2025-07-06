// Detect if we're on GitHub Pages or local/other hosting
var GHPATH = '';
if (location.hostname === 'bodhirasa.github.io') {
  GHPATH = '/meditation-course-on-the-six-senses';
}

var APP_PREFIX = 'six-senses_';
var VERSION = 'version_001';
var CACHE_NAME = APP_PREFIX + VERSION;

// Files to cache - will be populated during build
var URLS = [];

self.addEventListener('install', function (e) {
  console.log('Installing cache : ' + CACHE_NAME);
  e.waitUntil(
    caches.open(CACHE_NAME).then(function (cache) {
      console.log('Opened cache');
      return cache.addAll(URLS);
    })
  );
});

self.addEventListener('activate', function (e) {
  e.waitUntil(
    caches.keys().then(function (keyList) {
      var cacheWhitelist = keyList.filter(function (key) {
        return key.indexOf(APP_PREFIX) === 0;
      });
      cacheWhitelist.push(CACHE_NAME);
      return Promise.all(keyList.map(function (key, i) {
        if (cacheWhitelist.indexOf(key) === -1) {
          console.log('Deleting cache : ' + keyList[i]);
          return caches.delete(keyList[i]);
        }
      }));
    })
  );
});

self.addEventListener('fetch', function (e) {
  console.log('Fetch request : ' + e.request.url);
  e.respondWith(
    caches.match(e.request).then(function (request) {
      if (request) { 
        console.log('Responding with cache : ' + e.request.url);
        return request;
      } else {       
        console.log('File is not cached, fetching : ' + e.request.url);
        return fetch(e.request);
      }
    })
  );
});