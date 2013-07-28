require 'spec_helper'

describe "AssignmentPages" do
  subject { page }

  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }

  before { sign_in teacher }

  describe "assignment show page" do
    let(:assignment) { FactoryGirl.create(:assignment, course: course) }

    before { visit assignment_path(assignment) }

    it { should have_content(assignment.name) }
    it { should have_content(assignment.description) }
    it { should have_content(course.name) }
  end

  describe "assignment creation page" do
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

  describe "assignment editing page" do
    let(:assignment) { FactoryGirl.create(:assignment, course: course) }
    let(:submit) { "Submit Changes" }

    before { visit edit_assignment_path(assignment) }

    it { should have_title('Edit Assignment') }

    describe "given bad information" do
      before do
        fill_in "Name", with: ""
        click_button submit
      end

      it { should have_selector('.alert.alert-error') }
      it { should have_title('Edit Assignment') }
    end

    describe "given good information" do
      before { click_button submit }

      it { should have_selector('.alert.alert-success') }
    end
  end
end
