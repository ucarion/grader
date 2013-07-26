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
end
