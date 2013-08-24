module SubmissionsHelper
  def table_class_for_status(status)
    case status
    when Submission::Status::WAITING
      ""
    when Submission::Status::OUTPUT_CORRECT
      "success"
    when Submission::Status::OUTPUT_INCORRECT
      "error"
    end
  end
end
