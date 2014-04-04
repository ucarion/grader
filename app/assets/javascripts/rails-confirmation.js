$.rails.allowAction = function(link) {
  if (link.attr('data-confirm')) {
    $.rails.showConfirmationDialog(link);
    return false;
  } else {
    return true;
  }
}

$.rails.confirmed = function(link) {
  link.removeAttr('data-confirm');
  link.trigger('click.rails');
}

$.rails.showConfirmationDialog = function(link) {
  var headerMessage = link.attr('data-confirm-header');
  var message = link.attr('data-confirm');
  var confirmBtnClass = link.attr('data-confirm_btn_class') || 'danger';
  var confirmBtnMsg = link.attr('data-confirm-btn-msg');

  var html = [
    '<div class="modal fade" id="confirmationDialog">',
      '<div class="modal-dialog">',
        '<div class="modal-content">',
          '<div class="modal-header">',
            '<button class="close" data-dismiss="modal">&times;</button>',
            '<h4 class="modal-title">' + headerMessage + '</h4>',
          '</div>',
          '<div class="modal-body">',
            '<p>' + message + '</p>',
          '</div>',
          '<div class="modal-footer">',
            '<a data-dismiss="modal" class="btn btn-default">Cancel</a>',
            '<a data-dismiss="modal" class="btn btn-' +  confirmBtnClass + ' confirm">',
              confirmBtnMsg,
            '</a>',
          '</div>',
        '</div>',
      '</div>',
    '</div>'
  ].join('\n');

  var modal = $(html).modal();
  var confirmBtn = modal.find('.confirm');

  confirmBtn.click(function() {
    $.rails.confirmed(link);
  });
}
