require 'spec_helper'

describe Comment do
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course) }
  let(:submission) { FactoryGirl.create(:submission, assignment: assignment, author: student) }

  before do
    @comment = FactoryGirl.create(:comment, user: student, submission: submission)
  end

  subject { @comment }

  it { should respond_to(:content) }
  it { should respond_to(:user) }
  it { should respond_to(:submission) }

  it { should be_valid }

  describe "with no user" do
    before { @comment.user = nil }

    it { should_not be_valid }
  end

  describe "with no submission" do
    before { @comment.submission = nil }

    it { should_not be_valid }
  end

  describe "with no content" do
    before { @comment.content = "" }

    it { should_not be_valid }
  end
end
