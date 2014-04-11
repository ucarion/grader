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
    def diff_line_number(line_number, should_show_number)
      content_tag(:td, should_show_number ? line_number : "",
        class: 'diff-line-number')
    end

    source_a = File.read(submisison_a.main_file.code.path)
    source_b = File.read(submisison_b.main_file.code.path)

    diff = ::Diffy::Diff.new(source_a, source_b)
    chunks = diff.each_chunk.map do |chunk|
      first_char, lines = chunk[0], chunk[1..-1].split("\n")

      lines.map { |line| first_char + line }
    end.flatten

    line_number_a = line_number_b = 0

    chunks_as_html = chunks.reduce("".html_safe) do |acc, chunk|
      should_show_a = should_show_b = false
      line_class = ""

      case chunk[0]
      when '+'
        line_class = 'insertion'

        line_number_a += 1
        should_show_a = true
      when '-'
        line_class = 'deletion'

        line_number_b += 1
        should_show_b = true
      else
        line_number_a += 1
        line_number_b += 1
        should_show_a = should_show_b = true
      end

      text_to_display = if chunk.start_with?(' ')
        "&nbsp;"
      else
        ""
      end.html_safe + chunk

      acc + content_tag(:tr,
        diff_line_number(line_number_a, should_show_a) +
        diff_line_number(line_number_b, should_show_b) +
        content_tag(:td,
          content_tag(:span, text_to_display, class: "diff-line")
        ),

        class: line_class
      )
    end

    content_tag(:table, chunks_as_html,
      class: 'table table-bordered table-condensed table-diff')
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
