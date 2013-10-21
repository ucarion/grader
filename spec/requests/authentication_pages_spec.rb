require 'spec_helper'

describe "Authentication Pages" do
  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end

  describe "sign in" do
    before { visit signin_path }

    describe "with bad information" do
      before { click_button 'Sign in' }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }
    end

    describe "with good information" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it { should have_title(user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
  end

  describe "authorization" do
    describe "for actions requiring signin" do
      let(:user) { FactoryGirl.create(:user) }
      let(:other_user) { FactoryGirl.create(:user, name: "John Doe", email: "john@doe.com") }
      let(:course) { FactoryGirl.create(:course, teacher: other_user) }
      let(:assignment) { FactoryGirl.create(:assignment, course: course) }

      describe "when trying to edit a user" do
        before { visit edit_user_path(user) }

        it { should have_selector('.alert.alert-error') }
      end

      describe "when trying to create a course" do
        before { visit new_course_path }

        it { should have_selector('.alert.alert-error') }
      end

      describe "when editing a course" do
        before { visit edit_course_path(course) }

        it { should have_selector('.alert.alert-error') }
      end

      describe "when trying to create an assignment" do
        before { visit new_course_assignment_path(course) }

        it { should have_title('Sign in') }
      end

      describe "when editing an assignment" do
        before { visit edit_assignment_path(assignment) }

        it { should have_title('Sign in') }
      end

      describe "as the correct user" do
        before { sign_in(user) }

        describe "visiting another person's edit page" do
          before { visit edit_user_path(other_user) }

          it { should_not have_title('Edit Account') }
        end

        describe "visiting another person's profile page" do
          before { visit user_path(other_user) }

          it { should have_title(other_user.name) }
        end

        describe "editing another person's course" do
          before { visit edit_course_path(course) }

          it { should_not have_title('Edit Course') }
        end

        describe "editing another person's assignment" do
          before { visit edit_assignment_path(assignment) }

          it { should_not have_title('Edit Assignment') }
        end
      end

      describe "as a non-admin" do
        before { sign_in(user, no_capybara: true ) }

        describe "submitting a DELETE request to Users#destroy" do
          before { delete user_path(other_user) }

          specify { expect(response).to redirect_to(root_path) }
        end
      end
    end
  end
end
