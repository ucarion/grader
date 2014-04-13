module SubmissionsHelper
  def table_class_for_status(status)
    case status
    when Submission::Status::WAITING
      ""
    when Submission::Status::OUTPUT_CORRECT
      "success"
    when Submission::Status::OUTPUT_INCORRECT
      "danger"
    end
  end

  def status_label(submission)
    color, text = "", ""
    case submission.status
    when Submission::Status::WAITING
      color, text = "default", "Waiting"
    when Submission::Status::OUTPUT_CORRECT
      color, text = "success", "Tests passed"
    when Submission::Status::OUTPUT_INCORRECT
      color, text = "danger", "Tests failed"
    end

    content_tag(:label, text, class: "label label-#{color}")
  end

  def sanitize_for_comparison(output)
    output.gsub("\r", "").strip
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
