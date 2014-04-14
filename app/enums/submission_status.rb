class SubmissionStatus < ClassyEnum::Base
end

class SubmissionStatus::Waiting < SubmissionStatus
  def css_class
    "default"
  end

  def text_message
    "Waiting"
  end
end

class SubmissionStatus::Incorrect < SubmissionStatus
  def css_class
    "danger"
  end

  def text_message
    "Tests failed"
  end
end

class SubmissionStatus::Correct < SubmissionStatus
  def css_class
    "success"
  end

  def text_message
    "Tests failed"
  end
end
