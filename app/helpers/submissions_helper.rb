module SubmissionsHelper
  def status_label(status)
    content_tag(:label, status.text_message,
      class: "label label-#{status.css_class}")
  end

  def actual_output_col(submission, &block)
    css_class = submission.status.tested? ? 'col-md-6' : 'col-md-12'

    content_tag(:div, class: css_class, &block)
  end

  # Clean up a string to see if a submission's output is correct. Removes all of
  # the following:
  #
  #   - Carriage returns
  #   - Whitespace at end of lines (i.e. "hello    \n" -> "hello\n")
  #   - Leading and trailing whitespace
  #
  # Note that the modified string must still, to a human, resemble the original
  # string. This is because this method is also used to sanitize outputs before
  # diff-ing them.
  def sanitize_for_comparison(output)
    output.gsub("\r", "").each_line.map do |line|
      # replace whitespace preceding newline with just a newline
      line.gsub(/\s+\n/, "\n")
    end.join.strip
  end

  def highlighted_code(submission, code)
    Pygments.highlight(tabs_to_spaces(code),
      lexer: submission.assignment.course.language)
  end

  def sort_links(key, icon_type)
    icon = "sort-#{icon_type}"

    desc = sort_link(key, 'desc', "#{icon}-desc")
    asc = sort_link(key, 'asc', "#{icon}-asc")

    desc + asc
  end

  private

  def tabs_to_spaces(code)
    code.gsub(/\t/, ' ' * 4)
  end

  def sort_link(key, direction, icon)
    link_to(fa_icon(icon), sort: key, order: direction)
  end
end
