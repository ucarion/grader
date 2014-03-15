require 'spec_helper'

describe User do
  before do
    @user = FactoryGirl.build(:user)
  end

  subject { @user }

  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:admin?) }
  it { should respond_to(:teacher?) }
  it { should respond_to(:taught_courses) }
  it { should respond_to(:enrolled_courses) }
  it { should respond_to(:assignments) }
  it { should respond_to(:submissions) }
  it { should respond_to(:comments) }
  it { should respond_to(:grade_in_course) }

  # default definition of user is valid
  it { should be_valid }

  it "validates for a first name" do
    @user.first_name = ""
    expect(@user).not_to be_valid
  end

  it "validates for a last name" do
    @user.last_name = ""
    expect(@user).not_to be_valid
  end

  it "uses first and last to create full name" do
    @user.first_name, @user.last_name = "John", "Doe"
    expect(@user.name).to eq "John Doe"
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

  describe "with admin status" do
    before do
      @user.save
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end


  describe "grade in course" do
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course, teacher: teacher) }

    before do
      @user.save

      5.times do |n|
        assignment = FactoryGirl.create(:assignment, course: course)
        FactoryGirl.create(:submission, author: @user, assignment: assignment, grade: n)
      end
    end

    it "should correctly find its total score in the course" do
      expect(@user.grade_in_course(course)).to eq (0 + 1 + 2 + 3 + 4)
    end
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

  describe "submissions" do
    describe "cascading deletions" do
      let(:teacher) { FactoryGirl.create(:teacher) }
      let(:course) { FactoryGirl.create(:course, teacher: teacher) }
      let(:assignment) { FactoryGirl.create(:assignment, course: course) }

      before do
        @user.save
        FactoryGirl.create(:submission, assignment: assignment, author: @user)
      end

      it "should cascade-destroy submissions on user submissions" do
        submissions = @user.submissions.to_a

        @user.destroy

        submissions.each do |submission|
          expect { Submission.find(submission) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
