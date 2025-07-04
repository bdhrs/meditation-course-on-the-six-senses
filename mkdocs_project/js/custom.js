document.addEventListener("DOMContentLoaded", () => {
    let lastScrollY = window.scrollY;
    const header = document.querySelector("header");

    window.addEventListener("scroll", () => {
        if (window.scrollY > lastScrollY) {
            // User is scrolling down - hide header
            header.style.transform = "translateY(-100%)";
        } else {
            // User is scrolling up - show header
            header.style.transform = "translateY(0)";
        }
        lastScrollY = window.scrollY;
    });

    // Register Service Worker for PWA functionality
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register('/meditation-course-on-the-six-senses/service-worker.js')
                .then((registration) => {
                    console.log('Service Worker registered with scope:', registration.scope);
                })
                .catch((error) => {
                    console.log('Service Worker registration failed:', error);
                });
        });
    }
});
