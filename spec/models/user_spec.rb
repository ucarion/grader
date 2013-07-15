require 'spec_helper'

describe User do
  before { @user = User.new(name: "Lauren Ipsum", email: "dolor@sit.am.et") }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
end
