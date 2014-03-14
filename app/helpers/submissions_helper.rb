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

  def highlighted_code(submission, code)
    Pygments.highlight(tabs_to_spaces(code),
      lexer: submission.assignment.course.language)
  end

  private

  def tabs_to_spaces(code)
    code.gsub(/\t/, ' ' * 4)
  end
end
