require 'spec_helper'

describe Submission do
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course) }

  before { @submission = student.submissions.create!(assignment_id: assignment.id) }

  subject { @submission }

  it { should respond_to(:author) }
  it { should respond_to(:assignment) }
  it { should respond_to(:source_code) }

  it { should be_valid }

  it { should have_attached_file(:source_code) }
  it { should validate_attachment_presence(:source_code) }

  describe "with no author" do
    before { @submission.author = nil }

    it { should_not be_valid }
  end

  describe "with no assignment" do
    before { @submission.assignment = nil }

    it { should_not be_valid }
  end
end
