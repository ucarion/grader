require 'spec_helper'

describe "AssignmentPages" do
  subject { page }

  describe "assignment creation page" do
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course, teacher: teacher) }

    before { visit new_course_assignment_path(course) }

    it { should have_title("Create an assignment") }

    let(:submit) { "Create Assignment" }

    describe "submitted with bad information" do
      it "should not create an assignment on submission" do
        expect { click_button submit }.not_to change(Assignment, :count)
      end
    end

    describe "submitted with good information" do
      before do
        fill_in "Name", with: "Course"
        fill_in "Description", with: "Description goes here ..."
      end

      it "should create a new assignment on click" do
        expect { click_button submit }.to change(Assignment, :count).by(1)
      end

      describe "after submitting" do
        before { click_button submit }

        it { should have_title course.name }
        it { should have_selector('.alert.alert-success', text: "Assignment") }
      end
    end
  end
end