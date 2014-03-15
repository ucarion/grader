require 'spec_helper'

describe SubmissionPolicy do
  subject { SubmissionPolicy }

  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course) }
  let(:submission) { FactoryGirl.build_stubbed(:submission, author: student, assignment: assignment) }

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

  permissions :override_max_attempts? do
    it "grants access to the teacher" do
      expect(subject).to permit(teacher, submission)
    end

    it "does not grant access to the student" do
      expect(subject).not_to permit(student, submission)
    end
  end

  permissions :create? do
    describe "due_time and grace_period" do
      it "allows submissions before due_time" do
        assignment.due_time = 1.day.from_now
        expect(subject).to permit(student, submission)
      end

      it "allows submissions after due_time during grace period" do
        assignment.due_time = 1.day.ago
        assignment.grace_period = 2

        expect(subject).to permit(student, submission)
      end

      it "does not allow submissions after grace period" do
        assignment.due_time = 2.days.ago
        assignment.grace_period = 1

        expect(subject).not_to permit(student, submission)
      end
    end

    it "prevents students from creating many submisisons for one assignment" do
      FactoryGirl.create(:submission, author: student, assignment: assignment)

      expect(subject).not_to permit(student, submission)
    end
  end

  permissions :destroy? do
    it "lets teachers destroy submissions" do
      expect(subject).to permit(teacher, submission)
    end

    it "doesnt let submisison authors destroy submissions" do
      expect(subject).not_to permit(student, submission)
    end
  end
end
