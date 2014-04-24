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

  describe "activity" do
    it "notifies the teacher when student comments" do
      comment_by_student = FactoryGirl.create(:comment,
        user: student, submission: submission)

      activity = comment_by_student.create_activity
      expect(activity.user).to eq teacher
    end

    it "notifies the student when student comments" do
      comment_by_teacher = FactoryGirl.create(:comment,
        user: teacher, submission: submission)

      activity = comment_by_teacher.create_activity
      expect(activity.user).to eq student
    end
  end

  describe "#notify_submission" do
    it "does not update last_graded_at when the commenter is the student" do
      comment_by_student = FactoryGirl.create(:comment,
        user: student, submission: submission)

      expect do
        comment_by_student.notify_submission
      end.not_to change(submission, :last_graded_at)
    end

    it "updates last_graded_at when the commenter is the teacher" do
      comment_by_teacher = FactoryGirl.create(:comment,
        user: teacher, submission: submission)

      expect do
        comment_by_teacher.notify_submission
      end.to change(submission, :last_graded_at)
    end
  end
end
