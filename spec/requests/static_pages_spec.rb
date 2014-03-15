require 'spec_helper'

describe "Static pages" do
  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_content('Grader') }
    it { should have_title('Grader') }

    describe "when logged in" do
      let(:teacher) { FactoryGirl.create(:user) }
      let(:student) { FactoryGirl.create(:user) }
      let(:course) { FactoryGirl.create(:course, teacher: teacher) }

      before { course.students << student }

      describe "as a teacher" do
        before do
          sign_in teacher
          visit root_path
        end

        it "should list taught courses" do
          expect(page).to have_content('teaching')
          expect(page).to have_content(course.name)
        end

        describe "courses with submissions" do
          before do
            2.times do
              assignment = FactoryGirl.create(:assignment, course: course)
              FactoryGirl.create(:submission, assignment: assignment,
                author: student)
            end

            visit current_path
          end

          it "shows a badge with their ungraded assignments" do
            expect(find('span.badge').text).to eq '2'
          end
        end
      end

      describe "as a student" do
        before do
          sign_in student
          visit root_path
        end

        it "should list enrolled courses" do
          expect(page).to have_content('enrolled')
          expect(page).to have_content(course.name)
        end

        it "provides a way to enroll into a course" do
          expect(page).to have_link('Enroll', href: enroll_courses_path)
        end
      end
    end
  end

  describe "Help page" do
    before { visit help_path }

    it { should have_content('Help') }
    it { should have_title('Grader | Help') }
  end

  describe "About page" do
    before { visit about_path }

    it { should have_content('About') }
    it { should have_title('Grader | About') }
  end

  describe "Header" do
    before { visit root_path }

    describe "when not logged in" do
      it { should have_link "Sign in", href: signin_path }
      it { should have_link "Sign up", href: signup_path }
    end

    describe "when logged in" do
      let(:user) { FactoryGirl.create(:user) }

      before { sign_in(user) }

      it { should have_link "Profile", href: user_path(user) }
      it { should have_link "Settings", href: edit_user_registration_path }
      it { should have_link "Sign out", href: signout_path }
    end
  end
end
