// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  $('.datepicker').datepicker();
  $('.code-field').autosize();

  if ($('#assignment_grace_period').length) {
    var days = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ];

    var months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    var updateGracePeriodMessage = function() {
      var dueTimeField = $('#assignment_due_time').val();

      var dueTimeParts = dueTimeField.split('/');
      var year = parseInt(dueTimeParts[2], 10);
      var month = parseInt(dueTimeParts[0], 10) - 1;
      var day = parseInt(dueTimeParts[1], 10);

      var dueTime = new Date(year, month, day);

      var gracePeriod = parseInt($('#assignment_grace_period').val(), 10);
      var milliSecsOfGracePeriod = 24 * 60 * 60 * 1000 * gracePeriod;

      var endGrace = new Date(dueTime.getTime() + milliSecsOfGracePeriod);
      var endGraceMsg = days[endGrace.getDay()] + ', ' +
        months[endGrace.getMonth()] + ' ' + endGrace.getDate();

      var fullMessage;

      if (isNaN(endGrace.getTime())) {
        fullMessage = '';
      } else {
        fullMessage = 'Grace period will end on: ' + endGraceMsg;
      }

      $('#grace-period-message').text(fullMessage);
    };

    $('#assignment_grace_period, #assignment_due_time').on('change keyup',
      updateGracePeriodMessage);
  }

  if ($('#assignment_should_run_tests').length) {
    var expectedOutputTextarea = $('#assignment_expected_output');

    $('#assignment_should_run_tests').change(function() {
      expectedOutputTextarea.attr('disabled', !$(this).is(':checked'));
    });
  }
});
