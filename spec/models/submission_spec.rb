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
end
