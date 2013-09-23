require 'spec_helper'

describe SourceFile do
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course, input: "1 2 3 4 5") }
  let(:submission) { FactoryGirl.create(:submission, author: student, assignment: assignment) }

  before do
    @source_file = submission.source_files.create!(code: submission_file("valid.rb"))
  end

  subject { @source_file }

  it { should be_valid }

  it { should have_attached_file(:code) }
  it { should validate_attachment_presence(:code) }
end
