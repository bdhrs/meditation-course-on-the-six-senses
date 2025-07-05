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

});
