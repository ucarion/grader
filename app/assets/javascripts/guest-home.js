$(function() {
  var setColumnsEqualHeight = function() {
    var columns = $('#how-it-works > div');

    var heights = columns.map(function() {
      return $(this).height();
    });

    var maxHeight = Math.max.apply(null, heights);

    columns.each(function() {
      $(this).height(maxHeight);
    });
  };

  var makeAnimatedScrollLink = function() {
    var navbarHeight = 50;

    $('.smooth-scroll').click(function(e) {
      e.preventDefault();

      $('html, body').animate({
        scrollTop: $(this.hash).offset().top - navbarHeight
      }, 1000);
    });
  };

  // sets the multiple feature columns to be of equal height
  if ($('#how-it-works').length) {
    setColumnsEqualHeight();
    makeAnimatedScrollLink();
  }
})
