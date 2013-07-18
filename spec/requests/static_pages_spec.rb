require 'spec_helper'

describe "Static pages" do
  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_content('Grader') }
    it { should have_title('Grader') }
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
    end

    describe "when logged in" do
      let(:user) { FactoryGirl.create(:user) }

      before { sign_in(user) }

      it { should have_link "Profile", href: user_path(user) }
      it { should have_link "Settings", href: edit_user_path(user) }
      it { should have_link "Sign out", href: signout_path }
    end
  end
end
