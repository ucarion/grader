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

  def diff_between(submisison_a, submisison_b)
    source_a = File.read(submisison_a.main_file.code.path)
    source_b = File.read(submisison_b.main_file.code.path)

    ::Diffy::Diff.new(source_a, source_b, include_plus_and_minus_in_html: true).to_s(:html)
  end
end
