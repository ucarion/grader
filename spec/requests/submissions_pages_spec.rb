require 'spec_helper'

describe "SubmissionsPages" do
  subject { page }

  describe "show page" do
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course, teacher: teacher) }
    let(:assignment) { FactoryGirl.create(:assignment, course: course) }
    let(:student) { FactoryGirl.create(:student) }
    let(:submission) { student.submissions.create!(assignment: assignment) }

    before { visit submission_path(submission) }

    it { should have_content(student.name) }
    it { should have_content(assignment.name) }
  end
end
