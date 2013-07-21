require 'spec_helper'

describe Course do
  let(:teacher) { FactoryGirl.create(:teacher) }

  before do
    @course = teacher.taught_courses.build(name: "Example")
  end

  subject { @course }

  it { should respond_to(:teacher) }
  it { should respond_to(:students) }

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
end
