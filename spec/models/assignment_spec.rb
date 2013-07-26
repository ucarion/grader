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
end
