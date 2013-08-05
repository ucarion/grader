require 'spec_helper'

describe Course do
  let(:teacher) { FactoryGirl.create(:teacher) }

  before do
    @course = teacher.taught_courses.build(name: "Example", description: "Description")
  end

  subject { @course }

  it { should respond_to(:name) }
  it { should respond_to(:description) }
  it { should respond_to(:teacher) }
  it { should respond_to(:students) }
  it { should respond_to(:assignments) }

  its(:teacher) { should eq teacher }

  it { should be_valid }

  describe "when teacher_id is not present" do
    before { @course.teacher_id = nil }

    it { should_not be_valid }
  end

  describe "when name is not present" do
    before { @course.name = "" }

    it { should_not be_valid }
  end

  describe "when description is not present" do
    before { @course.description = "" }

    it { should_not be_valid }
  end

  describe "assignment association" do
    before { @course.save! }

    let!(:assignment1) { FactoryGirl.create(:assignment, course: @course, due_time: 2.days.from_now) }
    let!(:assignment2) { FactoryGirl.create(:assignment, course: @course, due_time: 1.day.from_now) }

    it "should return soon-to-be-due assignments first" do
      expect(@course.assignments).to eq [assignment2, assignment1]
    end

    it "should destroy dependent assignments on deletion" do
      assignments = @course.assignments.to_a

      @course.destroy

      assignments.each do |assignment|
        expect { Assignment.find(assignment) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
