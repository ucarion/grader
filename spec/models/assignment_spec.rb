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
end
