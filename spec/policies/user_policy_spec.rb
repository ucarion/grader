require 'spec_helper'

describe UserPolicy do
  subject { UserPolicy }

  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:other_student) { FactoryGirl.create(:student) }

  permissions :show_email? do
    it "does not show emails to non-logged-in users" do
      expect(subject).not_to permit(nil, student)
    end

    it "shows teachers their students' emails" do
      course.students << student
      expect(subject).to permit(teacher, student)
    end

    it "does not show students' emails to any random teacher" do
      # `teacher` is a teacher, but it does not teach any courses student is
      # enrolled in.
      expect(subject).not_to permit(teacher, student)
    end

    it "does not let other users see students' emails" do
      expect(subject).not_to permit(other_student, student)
    end
  end
end
