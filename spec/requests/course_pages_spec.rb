require 'spec_helper'

describe "CoursePages" do
  subject { page }

  describe "course creation page" do
    before do
      sign_in(FactoryGirl.create(:user))
      visit new_course_path
    end

    let(:submit) { "Create Course" }

    it { should have_title('Create new course') }

    describe "given invalid information" do
      it "should not create a course on submission" do
        expect { click_button submit }.not_to change(Course, :count)
      end
    end

    describe "given valid information" do
      before do
        fill_in "Name", with: "Example"
        fill_in "Description", with: "Text goes here ..."
      end

      it "should create a new course on submission" do
        expect { click_button submit }.to change(Course, :count).by(1)
      end

      describe "after creating the course" do
        before { click_button submit }

        it { should have_title("Example") }
        it { should have_selector('div.alert.alert-success', text: "Course") }
      end
    end
  end
end
