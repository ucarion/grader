require 'spec_helper'

describe "SubmissionsPages" do
  subject { page }

  describe "show page" do
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course, teacher: teacher) }
    let(:assignment) { FactoryGirl.create(:assignment, course: course) }
    let(:student) { FactoryGirl.create(:student) }

    let(:submission) do
      student.submissions.create!(assignment: assignment,
        source_code: File.new(Rails.root + 'spec/example_files/valid.rb'))
    end

    before { visit submission_path(submission) }

    it { should have_content(student.name) }
    it { should have_content(assignment.name) }

    it "should show the submission's source code" do
      source = File.read(submission.source_code.path)
      expect(page).to have_content(source)
    end
  end
end
