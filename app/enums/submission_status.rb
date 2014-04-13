class SubmissionStatus < ClassyEnum::Base
end

class SubmissionStatus::Waiting < SubmissionStatus
end

class SubmissionStatus::Incorrect < SubmissionStatus
end

class SubmissionStatus::Correct < SubmissionStatus
end
