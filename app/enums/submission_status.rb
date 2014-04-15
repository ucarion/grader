class SubmissionStatus < ClassyEnum::Base
  def tested?
    true
  end

  def actual_output_message
    "Actual Output"
  end
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
    "Tests passed"
  end
end

class SubmissionStatus::NotTested < SubmissionStatus
  def tested?
    false
  end

  def actual_output_message
    "Output"
  end

  def css_class
    "info"
  end

  def text_message
    "Not tested"
  end
end
