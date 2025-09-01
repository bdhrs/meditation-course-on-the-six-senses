document.addEventListener('DOMContentLoaded', () => {

    // --- Theme Toggle ---
    const themeToggle = document.getElementById('theme-toggle');
    const themeIcon = themeToggle.querySelector('.theme-icon');
    const body = document.body;

    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
        body.classList.add(savedTheme);
        // Update icon based on saved theme
        if (savedTheme === 'dark-mode') {
            // Change to moon icon
            themeIcon.src = 'static/images/theme-icon-moon.svg';
        } else {
            // Keep sun icon (default)
            themeIcon.src = 'static/images/theme-icon.svg';
        }
    }

    themeToggle.addEventListener('click', () => {
        if (body.classList.contains('dark-mode')) {
            body.classList.remove('dark-mode');
            localStorage.setItem('theme', 'light-mode');
            // Change to sun icon
            themeIcon.src = 'static/images/theme-icon.svg';
        } else {
            body.classList.add('dark-mode');
            localStorage.setItem('theme', 'dark-mode');
            // Change to moon icon
            themeIcon.src = 'static/images/theme-icon-moon.svg';
        }
    });

    // --- Status Toggle ---
    const statusToggle = document.getElementById('status-toggle');
    const statusIcon = statusToggle.querySelector('.status-icon');
    
    // Check if we're in online or offline mode
    // For now, we'll just toggle the icon as a visual indicator
    statusToggle.addEventListener('click', () => {
        // Toggle between online and offline icons
        if (statusIcon.src.includes('status-icon-offline.svg')) {
            // Currently showing offline icon, change to online icon
            statusIcon.src = 'static/images/status-icon.svg';
        } else {
            // Currently showing online icon, change to offline icon
            statusIcon.src = 'static/images/status-icon-offline.svg';
        }
    });

    // --- Disappearing Header ---
    let lastScrollY = window.scrollY;
    const header = document.getElementById('main-header');

    window.addEventListener('scroll', () => {
        if (window.scrollY > lastScrollY) {
            // Scrolling down
            header.classList.add('header-hidden');
        } else {
            // Scrolling up
            header.classList.remove('header-hidden');
        }
        lastScrollY = window.scrollY;
    }, { passive: true });

    // --- On-Page Table of Contents ---
    const tocContainer = document.querySelector('#on-page-toc ul');
    const mainContent = document.querySelector('.main-content');
    const headings = mainContent.querySelectorAll('h2, h3');

    if (headings.length > 0) {
        headings.forEach(heading => {
            const listItem = document.createElement('li');
            const link = document.createElement('a');
            
            // Create an ID for the heading if it doesn't have one
            if (!heading.id) {
                heading.id = heading.textContent.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
            }

            link.href = `#${heading.id}`;
            link.textContent = heading.textContent;
            
            listItem.appendChild(link);
            tocContainer.appendChild(listItem);
        });
    } else {
        document.querySelector('#on-page-toc').style.display = 'none';
    }

    // --- Menu Toggle ---
    const menuToggle = document.getElementById('menu-toggle');
    const sidebarLeft = document.querySelector('.sidebar-left');

    menuToggle.addEventListener('click', () => {
        // Toggle only the left sidebar
        sidebarLeft.classList.toggle('show');
    });
});
