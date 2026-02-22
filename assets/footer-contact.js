document.querySelectorAll('.footer-email-link').forEach(function (a) {
  a.addEventListener('click', function (e) {
    e.preventDefault();
    try {
      var u = atob("amVyZW15");
      var d = atob("b3RoZXJzZWx2ZXN3b3JraW5nLmdyb3Vw");
      if (u && d) location.href = 'mailto:' + u + '@' + d;
    } catch (_) {}
  });
});
