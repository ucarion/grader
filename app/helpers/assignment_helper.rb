module AssignmentHelper
  def time_left_message(assignment)
    human_due_time = assignment.due_time.strftime("%I:%M%p %B %d")

    if assignment.open?
      "Closes at #{human_due_time} (#{time_ago_in_words(assignment.due_time)} from now)"
    else
      "Closed since #{human_due_time} (#{time_ago_in_words(assignment.due_time)} ago)"
    end
  end

  def format_date(time)
    time.strftime("%m/%d/%Y")
  end

  def assignment_open_label(assignment)
    text, color, timestatus = if assignment.open?
      ["Open", "success", "open"]
    else
      ["Closed", "danger", "closed"]
    end

    content_tag(:label, text,
      class: "label label-#{color} timestatus timestatus-#{timestatus}")
  end

  def default_assignment_max_attempts
    5
  end

  def default_assignment_grace_period
    0
  end
end
