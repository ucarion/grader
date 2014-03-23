require 'spec_helper'

describe Assignment do
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }

  before do
    @assignment = FactoryGirl.create(:assignment, course: course)
  end

  subject { @assignment }

  it { should respond_to(:name) }
  it { should respond_to(:description) }
  it { should respond_to(:course) }
  it { should respond_to(:submissions) }
  it { should respond_to(:due_time) }
  it { should respond_to(:open?) }
  it { should respond_to(:closed?) }
  it { should respond_to(:point_value) }
  it { should respond_to(:expected_output) }
  it { should respond_to(:input) }
  it { should respond_to(:test_for_plagiarism!) }
  it { should respond_to(:max_attempts) }
  it { should respond_to(:grace_period) }

  its(:course) { should eq course }

  it { should be_valid }

  describe "with no name" do
    before { @assignment.name = "" }

    it { should_not be_valid }
  end

  describe "with no description" do
    before { @assignment.name = "" }

    it { should_not be_valid }
  end

  describe "with no course_id" do
    before { @assignment.course_id = nil }

    it { should_not be_valid }
  end

  describe "with no due_time" do
    before { @assignment.due_time = nil }

    it { should_not be_valid }
  end

  describe "with no point_value" do
    before { @assignment.point_value = nil }

    it { should_not be_valid }
  end

  describe "with a zero point_value" do
    before { @assignment.point_value = 0 }

    it { should_not be_valid }
  end

  describe "with a non-number point_value" do
    before { @assignment.point_value = "two" }

    it { should_not be_valid }
  end

  describe "with an empty expected_output" do
    before { @assignment.expected_output = nil }

    it { should be_valid }
  end

  describe "with an empty input" do
    before { @assignment.input = nil }

    it { should be_valid }
  end

  describe "max attempts" do
    describe "not present" do
      before { @assignment.max_attempts = nil }

      it { should_not be_valid }
    end

    describe "not a number" do
      before { @assignment.max_attempts = "two" }

      it { should_not be_valid }
    end

    describe "less than one" do
      before { @assignment.max_attempts = 0 }

      it { should_not be_valid }
    end
  end

  describe "grace period" do
    describe "not present" do
      before { @assignment.grace_period = nil }

      it { should_not be_valid }
    end

    describe "not a number" do
      before { @assignment.grace_period = "two" }

      it { should_not be_valid }
    end

    describe "less than zero" do
      before { @assignment.grace_period = -1 }

      it { should_not be_valid }
    end
  end


  describe "whose due time is not yet passed" do
    before { @assignment.due_time = 1.year.from_now }

    it { should be_open }
    it { should_not be_closed }
  end

  describe "whose due time is passed" do
    before { @assignment.due_time = 1.year.ago }

    it { should_not be_open }
    it { should be_closed }
  end

  describe "submission association" do
    let(:student) { FactoryGirl.create(:student) }

    before do
      @assignment.save!

      course.students << student

      2.times do
        FactoryGirl.create(:submission, assignment: @assignment, author: student)
      end
    end

    it "should destroy dependent submissions on deletion" do
      submissions = @assignment.submissions.to_a

      @assignment.destroy

      submissions.each do |submission|
        expect { Submission.find(submission) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "testing for plagiarism" do
    let(:student1) { FactoryGirl.create(:student) }
    let(:student2) { FactoryGirl.create(:student) }
    let(:student3) { FactoryGirl.create(:student) }

    before do
      course.students << student1
      course.students << student2

      # TODO do this in a less yucky fashion -- skip the source-file creation callback?
      cheat1 = FactoryGirl.create(:submission, assignment: @assignment, author: student1)
      cheat1.source_files.clear
      FactoryGirl.create(:source_file, code: submission_file("prime/doppel.rb"), submission: cheat1)

      cheat2 = FactoryGirl.create(:submission, assignment: @assignment, author: student2)
      cheat2.source_files.clear
      FactoryGirl.create(:source_file, code: submission_file("prime/ganger.rb"), submission: cheat2)

      cheat3 = FactoryGirl.create(:submission, assignment: @assignment, author: student3)
      cheat3.source_files.clear
      FactoryGirl.create(:source_file, code: submission_file("prime/original.rb"), submission: cheat3)

      @assignment.test_for_plagiarism!
    end

    it "should have found the plagiarized submissions" do
      cheat1 = student1.submissions.first
      cheat2 = student2.submissions.first
      noncheat = student3.submissions.first

      expect(cheat1.plagiarizing).to eq [ cheat2.id ]
      expect(cheat2.plagiarizing).to eq [ cheat1.id ]
      expect(noncheat.plagiarizing).to be_empty
    end
  end

  describe "activities" do
    it "notifies all students in a course of a new assignment" do
      5.times do
        user = FactoryGirl.create(:student)

        course.students << user
      end

      activities = @assignment.create_activities
      users = activities.map { |activity| activity.user }

      expect(users).to match_array(course.students)
    end
  end
end
