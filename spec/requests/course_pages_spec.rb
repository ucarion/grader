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

  describe "course description page" do
    let(:teacher) { FactoryGirl.create(:user) }
    let(:user) { FactoryGirl.create(:user) }
    let(:course) { teacher.taught_courses.create!(name: "Test", description: "Class") }
    
    describe "joining a class" do
      describe "when not logged in" do
        before { visit course_path(course) }

        it { should_not have_selector('.btn-enroll') }
      end

      describe "when logged in" do
        before do
          sign_in user
          visit course_path(course)
        end

        it { should have_selector('.btn-enroll') }

        describe "clicking on the enroll button" do
          before { click_button "Enroll in this Course" }

          it "should make the current user enroll into the course" do
            expect(user.enrolled_courses).to include(course)
            expect(course.students).to include(user)
          end

          describe "after having already enrolled" do
            it { should_not have_selector('.btn-enroll') }
          end
        end
      end
    end
  end
end
