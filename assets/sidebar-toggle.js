(function () {
  var toggle = document.querySelector('.menu-toggle');
  var sidebar = document.getElementById('sidebar');
  var backdrop = document.getElementById('sidebar-backdrop');
  var body = document.body;

  if (!toggle || !sidebar) return;

  function isMobile() {
    return window.matchMedia('(max-width: 768px)').matches;
  }

  function openSidebar() {
    if (!isMobile()) return;
    body.classList.add('sidebar-open');
    toggle.setAttribute('aria-expanded', 'true');
    toggle.setAttribute('aria-label', 'Close menu');
    backdrop.setAttribute('aria-hidden', 'false');
  }

  function closeSidebar() {
    body.classList.remove('sidebar-open');
    toggle.setAttribute('aria-expanded', 'false');
    toggle.setAttribute('aria-label', 'Open menu');
    backdrop.setAttribute('aria-hidden', 'true');
  }

  function toggleSidebar() {
    if (body.classList.contains('sidebar-open')) {
      closeSidebar();
    } else {
      openSidebar();
    }
  }

  toggle.addEventListener('click', toggleSidebar);
  backdrop.addEventListener('click', closeSidebar);

  // Close sidebar when clicking a link (navigate away)
  sidebar.addEventListener('click', function (e) {
    if (e.target.tagName === 'A' && e.target.getAttribute('href')) {
      closeSidebar();
    }
  });

  // Close on resize to desktop
  window.addEventListener('resize', function () {
    if (!isMobile() && body.classList.contains('sidebar-open')) {
      closeSidebar();
    }
  });
})();
