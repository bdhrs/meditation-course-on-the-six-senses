document.addEventListener("DOMContentLoaded", () => {
  // --- Theme Toggle ---
  const themeToggle = document.getElementById("theme-toggle");
  const themeIcon = themeToggle.querySelector(".theme-icon");
  const body = document.body;

  const savedTheme = localStorage.getItem("theme");
  if (savedTheme) {
    document.documentElement.classList.add(savedTheme);
    // Update icon based on saved theme
    if (savedTheme === "dark-mode") {
      // Change to moon icon
      themeIcon.src = "static/images/theme-icon-moon.svg";
    } else {
      // Keep sun icon (default)
      themeIcon.src = "static/images/theme-icon.svg";
    }
  }

  themeToggle.addEventListener("click", () => {
    if (document.documentElement.classList.contains("dark-mode")) {
      document.documentElement.classList.remove("dark-mode");
      localStorage.setItem("theme", "light-mode");
      // Change to sun icon
      themeIcon.src = "static/images/theme-icon.svg";
    } else {
      document.documentElement.classList.add("dark-mode");
      localStorage.setItem("theme", "dark-mode");
      // Change to moon icon
      themeIcon.src = "static/images/theme-icon-moon.svg";
    }
  });

  // --- Status Toggle ---
  // Commented out since offline mode feature is not yet implemented
  /*
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
    */
  // --- Disappearing Header and Side Panels ---
  const header = document.getElementById("main-header");
  const sidebarLeft = document.querySelector(".sidebar-left");
  const sidebarRight = document.querySelector(".sidebar-right");
  const scrollableContainer = document.querySelector(".center-pane-wrapper");
  let lastScrollTop = 0;
  const delta = 5; // Minimum scroll change to trigger action
  const headerHeight = header.offsetHeight;

  if (scrollableContainer) {
    scrollableContainer.addEventListener(
      "scroll",
      () => {
        const st = scrollableContainer.scrollTop;

        // Make sure we scroll more than delta
        if (Math.abs(lastScrollTop - st) <= delta) {
          return;
        }

        const scrollHeight = scrollableContainer.scrollHeight;
        const clientHeight = scrollableContainer.clientHeight;
        const isAtBottom = st + clientHeight >= scrollHeight - 50;
        const isAtTop = st < 50;

        if (isAtTop || isAtBottom) {
          // Always show header and side panels if at the top or bottom of the page
          header.classList.remove("header-hidden");
          sidebarLeft.classList.remove("sidebar-hidden");
          sidebarRight.classList.remove("sidebar-hidden");
        } else {
          // Otherwise (scrolling in the middle), hide them
          header.classList.add("header-hidden");
          sidebarLeft.classList.add("sidebar-hidden");
          sidebarRight.classList.add("sidebar-hidden");
        }

        lastScrollTop = st;
      },
      { passive: true }
    );
  }

  // --- On-Page Table of Contents ---
  const tocContainer = document.querySelector("#on-page-toc ul");
  const mainContent = document.querySelector(".main-content");
  const headings = mainContent.querySelectorAll("h2, h3");

  if (headings.length > 0) {
    headings.forEach((heading) => {
      const listItem = document.createElement("li");
      const link = document.createElement("a");

      // Create an ID for the heading if it doesn't have one
      if (!heading.id) {
        heading.id = heading.textContent
          .toLowerCase()
          .replace(/\s+/g, "-")
          .replace(/[^a-z0-9-]/g, "");
      }

      link.href = `#${heading.id}`;
      link.textContent = heading.textContent;

      // Add different classes for h2 and h3 headings
      if (heading.tagName === "H2") {
        listItem.classList.add("toc-h2");
      } else if (heading.tagName === "H3") {
        listItem.classList.add("toc-h3");
      }

      listItem.appendChild(link);
      tocContainer.appendChild(listItem);
    });
  } else {
    document.querySelector("#on-page-toc").style.display = "none";
  }

  // --- Menu Toggle ---
  const menuToggle = document.getElementById("menu-toggle");

  menuToggle.addEventListener("click", () => {
    // Toggle only the left sidebar
    sidebarLeft.classList.toggle("show");
  });

  // --- Footer Navigation ---
  const prevButton = document.querySelector(".prev-page");
  const nextButton = document.querySelector(".next-page");

  if (prevButton && !prevButton.classList.contains("disabled")) {
    prevButton.addEventListener("click", (e) => {
      const href = prevButton.getAttribute("data-href");
      if (href) {
        window.location.href = href;
      }
    });
  }

  if (nextButton && !nextButton.classList.contains("disabled")) {
    nextButton.addEventListener("click", (e) => {
      const href = nextButton.getAttribute("data-href");
      if (href) {
        window.location.href = href;
      }
    });
  }
});
