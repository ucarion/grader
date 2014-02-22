require 'spec_helper'

describe CoursePolicy do
  subject { CoursePolicy }

  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }

  permissions :enroll? do
    it "prevents students from double-enrolling" do
      course.students << student
      expect(subject).not_to permit(student, course)
    end
  end
end
