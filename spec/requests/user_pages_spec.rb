require 'spec_helper'

describe "User Pages" do
  subject { page }

  describe "signup page" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    it { should have_content('Sign up') }
    it { should have_title('Grader | Sign up') }

    # user_spec already tests for User validations; any
    # invalid submission should do the trick here
    describe "submitted with invalid information" do
      it "should not create a new user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "submitted with valid information" do
      before do
        fill_in "Name", with: "Lauren Ipsum"
        fill_in "Email", with: "dolor@sit.am.et"
        fill_in "Password", with: "password"
        fill_in "Password confirmation", with: "password"
      end

      it "should create a new user" do
        expect { click_button submit}.to change(User, :count).by(1)
      end

      describe "after making the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: "dolor@sit.am.et") }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }

    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_content(user.email) }
    it { should have_title(user.name)}
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit edit_user_path(user) }

    describe "page" do
      it { should have_title('Edit Account') }
      it { should have_content('Edit Account') }
    end

    describe "with bad information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end
  end
end
