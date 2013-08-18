require 'spec_helper'

describe Submission do
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course) }

  before do
    @submission = student.submissions.create!(assignment_id: assignment.id, 
      source_code: File.new(Rails.root + 'spec/example_files/valid.rb'), grade: 1)
  end

  subject { @submission }

  it { should respond_to(:author) }
  it { should respond_to(:assignment) }
  it { should respond_to(:source_code) }
  it { should respond_to(:grade) }
  it { should respond_to(:comments) }

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

  describe "comment association" do
    before do
      @submission.save!

      course.students << student
    end

    let!(:comment1) { FactoryGirl.create(:comment, user: student, submission: @submission, created_at: 1.day.ago) }
    let!(:comment2) { FactoryGirl.create(:comment, user: student, submission: @submission, created_at: 2.days.ago) }

    it "should return older comments first" do
      expect(@submission.comments).to eq [comment2, comment1]
    end

    it "should destroy dependent submissions on deletion" do
      comments = @submission.comments.to_a

      @submission.destroy

      comments.each do |comment|
        expect { Comment.find(comment) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
