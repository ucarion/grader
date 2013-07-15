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
end
