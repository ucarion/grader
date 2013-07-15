require 'spec_helper'

describe User do
  before { @user = User.new(name: "Lauren Ipsum", email: "dolor@sit.am.et") }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }

  # default definition of user is valid
  it { should be_valid }

  describe "when name is blank" do
    before { @user.name = "" }

    it { should_not be_valid }
  end

  describe "when email is blank" do
    before { @user.email = "" }

    it { should_not be_valid }
  end

  describe "when email is not correct" do
    it "should not be valid" do
      bad_emails = %w{a@b a@b,c @a.b a@@b.c}

      bad_emails.each do |email|
        @user.email = email

        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email is correct" do
    it "should be valid" do
      good_emails = %w{a@b.c a.b@c.d a@b.c.d a+b@c.d}

      good_emails.each do |email|
        @user.email = email

        expect(@user).to be_valid
      end
    end
  end
end
