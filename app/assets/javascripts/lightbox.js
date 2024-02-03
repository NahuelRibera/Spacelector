// app/assets/javascripts/lightbox.js

document.addEventListener("DOMContentLoaded", function() {
  lightbox.option({
    'albumLabel': 'Image %1 of %2',
    'alwaysShowNavOnTouchDevices': false,
    'fadeDuration': 200,
    'fitImagesInViewport': true,
    'imageFadeDuration': 200,
    'maxWidth': 800,
    'maxHeight': 600,
    'positionFromTop': 50,
    'resizeDuration': 200,
    'showImageNumberLabel': true,
    'wrapAround': false,
    'disableScrolling': false,
    'sanitizeTitle': false
  });
});
