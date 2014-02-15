require 'spec_helper'

describe SubmissionPolicy do
  subject { SubmissionPolicy }

  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course) }
  let(:submission) { FactoryGirl.create(:submission, author: student, assignment: assignment) }

  before do
    course.students << student
  end

  permissions :update? do
    describe "max attempts" do
      before { submission.num_attempts = assignment.max_attempts + 1 }

      it "does not allow updating if too many attempts already" do
        expect(subject).not_to permit(student, submission)
      end
    end
  end
end
