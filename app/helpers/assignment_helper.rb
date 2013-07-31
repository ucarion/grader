module AssignmentHelper
  def time_left_message(assignment)
    human_due_time = assignment.due_time.strftime("%I:%M%p %B %d")

    if assignment.open?
      "Closes at #{human_due_time} (#{time_ago_in_words(assignment.due_time)} from now)"
    else
      "Closed since #{human_due_time} (#{time_ago_in_words(assignment.due_time)} ago)"
    end
  end
end
