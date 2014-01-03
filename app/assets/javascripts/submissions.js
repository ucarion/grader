// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  if ($('#back_to_list_submissions').length) {
    // the properties of the popover are in HTML data-* attributes already.
    $('#back_to_list_submissions').popover();
  }
});
