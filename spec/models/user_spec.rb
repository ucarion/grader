require 'spec_helper'

describe User do
  before do
    @user = User.new(name: "Lauren Ipsum",
                        email: "dolor@sit.am.et",
                        password: "consectetur",
                        password_confirmation: "consectetur")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin?) }
  it { should respond_to(:taught_courses) }
  it { should respond_to(:enrolled_courses) }
  it { should respond_to(:assignments) }
  it { should respond_to(:submissions) }
  it { should respond_to(:comments) }

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

  describe "when email has already been taken" do
    before do
      copycat = @user.dup
      copycat.email.upcase!
      copycat.save
    end

    it { should_not be_valid }
  end

  describe "when passwords don't match" do
    before { @user.password_confirmation = "something else" }

    it { should_not be_valid }
  end

  describe "when password is empty" do
    before { @user.password = @user.password_confirmation = " " }

    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "when passwords are too short" do
    before { @user.password = @user.password_confirmation = "12345" }

    it { should_not be_valid }
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "remember token" do
    before { @user.save }

    its(:remember_token) { should_not be_blank }
  end

  describe "with admin status" do
    before do
      @user.save
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "course associations" do
    describe "with taught courses" do
      # order does matter here; save the user or else you can't create
      # a class with it
      before { @user.save }

      let!(:course) { FactoryGirl.create(:course, teacher: @user) }

      its(:taught_courses) { should_not be_empty }
      its(:taught_courses) { should include(course) }

      it "should destroy associated courses upon deletion" do
        courses = @user.taught_courses.to_a

        @user.destroy

        courses.each do |course|
          expect { Course.find(course) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "enrolled in classes" do
      let(:teacher) { FactoryGirl.create(:teacher) }
      let!(:course) { FactoryGirl.create(:course, teacher: teacher) }

      before { course.students << @user }

      its(:enrolled_courses) { should_not be_empty }
      its(:enrolled_courses) { should include(course) }
    end
  end

  describe "assignments" do
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course1) { FactoryGirl.create(:course, teacher: teacher) }
    let(:course2) { FactoryGirl.create(:course, teacher: teacher) }
    let!(:assignment1) { FactoryGirl.create(:assignment, course: course1, due_time: 3.days.from_now) }
    let!(:assignment2) { FactoryGirl.create(:assignment, course: course2, due_time: 1.day.from_now) }
    let!(:assignment3) { FactoryGirl.create(:assignment, course: course2, due_time: 2.days.ago) }

    before do
      @user.save

      @user.enrolled_courses << course1 << course2
    end

    it "should return all assignments ordered by due time, with soon-due ones first" do
      expect(@user.assignments).to eq [assignment3, assignment2, assignment1]
    end

    it "should only due assignments that are still open if we specify only_open: true" do
      expect(@user.assignments(only_open: true)).to eq [assignment2, assignment1]
    end
  end
end
