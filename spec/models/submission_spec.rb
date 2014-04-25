require 'spec_helper'

describe Submission do
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course, input: "1 2 3 4 5") }

  before do
    # @submission = student.submissions.create!(assignment_id: assignment.id)
    # @submission.source_files.create!(code: submission_file("valid.rb"), main: true)
    @submission = FactoryGirl.create(:submission, author: student, assignment: assignment)
  end

  subject { @submission }

  it { should respond_to(:author) }
  it { should respond_to(:assignment) }
  it { should respond_to(:source_files) }
  it { should respond_to(:grade) }
  it { should respond_to(:comments) }
  it { should respond_to(:output) }
  it { should respond_to(:status) }
  it { should respond_to(:main_file) }
  it { should respond_to(:num_attempts) }
  it { should respond_to(:max_attempts) }
  it { should respond_to(:max_attempts_override) }
  it { should respond_to(:last_submitted_at) }
  it { should respond_to(:last_graded_at) }

  it { should be_valid }

  describe "with no author" do
    before { @submission.author = nil }

    it { should_not be_valid }
  end

  describe "with no assignment" do
    before { @submission.assignment = nil }

    it { should_not be_valid }
  end

  describe "with no source files" do
    before { @submission.source_files.clear }

    it { should_not be_valid }
  end

  describe "with no main files" do
    before { @submission.source_files.first.update_attributes(main: false) }

    it { should_not be_valid }
  end

  describe "with multiple main files" do
    before do
      FactoryGirl.create(:source_file, submission: @submission, main: true)
      @submission.reload
    end

    it { should_not be_valid }
  end

  describe "grade" do
    it "does not require a grade" do
      @submission.grade = nil

      expect(subject).to be_valid
    end

    it "requires numerical grades" do
      @submission.grade = "three"

      expect(subject).not_to be_valid
    end

    it "works fine with decimal values" do
      @submission.grade = "3.14"

      expect(subject).to be_valid
    end
  end

  describe "num attempts" do
    it "should default to zero" do
      expect(@submission.num_attempts).to eq 0
    end
  end

  describe "max attempts override" do
    describe "can be non-present" do
      before { @submission.max_attempts_override = nil }
      it { should be_valid }
    end

    describe "if present" do
      describe "must be a number" do
        before { @submission.max_attempts_override = "two" }
        it { should_not be_valid }
      end

      describe "must be positive" do
        before { @submission.max_attempts_override = 0 }
        it { should_not be_valid }
      end
    end
  end

  describe "max attempts" do
    describe "when no override is given" do
      before do
        assignment.max_attempts = 3
      end

      it "should be the assignment's max attempts" do
        expect(@submission.max_attempts).to eq 3
      end
    end

    describe "when an override is given" do
      before do
        assignment.max_attempts = 3
        @submission.max_attempts_override = 2
      end

      it "should use the override value" do
        expect(@submission.max_attempts).to eq 2
      end
    end
  end

  describe "comment association" do
    before do
      @submission.save!

      course.students << student
    end

    let!(:comment1) { FactoryGirl.create(:comment, user: student, submission: @submission, created_at: 1.day.ago) }
    let!(:comment2) { FactoryGirl.create(:comment, user: student, submission: @submission, created_at: 2.days.ago) }

    it "should return older comments first" do
      expect(@submission.comments).to eq [comment2, comment1]
    end

    it "should destroy dependent submissions on deletion" do
      comments = @submission.comments.to_a

      @submission.destroy

      comments.each do |comment|
        expect { Comment.find(comment) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "output" do
    before do
      @submission.execute_code!
      @submission.reload
    end

    its(:output) { should eq "Hello, world!\n" }
  end

  describe "input" do
    before do
      @submission.source_files.first.update_attributes(code: File.new(Rails.root + 'spec/example_files/inreader.rb'))

      @submission.execute_code!
      @submission.reload
    end

    its(:output) { should eq "[1, 4, 9, 16, 25]\n" }
  end

  describe "status" do
    describe "before being executed" do
      its(:status) { should be_waiting }
    end

    describe "after being executed" do
      describe "and the output is the expected output" do
        before do
          assignment.update_attributes(expected_output: "Hello, world!")
          @submission.execute_code!
          @submission.reload
        end

        its(:status) { should be_correct }
      end

      describe "and the output is not the expected output" do
        before do
          assignment.update_attributes(expected_output: "Something else")
          @submission.execute_code!
          @submission.reload
        end

        its(:status) { should be_incorrect }
      end
    end
  end

  describe "multiple files" do
    before do
      @submission.source_files.clear

      course.update_attributes(language: :java)
      FactoryGirl.create(:source_file, code: submission_file("Refer.java"), submission: @submission)
      FactoryGirl.create(:source_file, code: submission_file("Referenced.java"),
                         submission: @submission, main: false)

      @submission.reload

      @submission.execute_code!
      @submission.reload
    end

    its(:output) { should eq "Hello, there!\n" }
  end

  describe "programming languages" do
    describe "java" do
      before do
        course.update_attributes!(language: :java)
        @submission.source_files.first.update_attributes!(code: submission_file("JavaExample.java"))

        @submission.execute_code!
        @submission.reload
      end

      its(:output) { should eq "1\n4\n9\n16\n25\n" }
    end

    describe "c" do
      before do
        course.update_attributes!(language: :c)
        @submission.source_files.first.update_attributes!(code: submission_file("c_example.c"))

        @submission.execute_code!
        @submission.reload
      end

      its(:output) { should eq "1\n4\n9\n16\n25\n" }
    end

    describe "c++" do
      before do
        course.update_attributes(language: :cpp)
        @submission.source_files.first.update_attributes!(code: submission_file("cpp_example.cpp"))

        @submission.execute_code!
        @submission.reload
      end

      its(:output) { should eq "1\n4\n9\n16\n25\n" }
    end

    describe "python" do
      before do
        course.update_attributes(language: :python)
        @submission.source_files.first.update_attributes!(code: submission_file("pyexample.py"))

        @submission.execute_code!
        @submission.reload
      end

      its(:output) { should eq "1\n4\n9\n16\n25\n" }
    end
  end

  describe "stderr" do
    before do
      course.update_attributes(language: :java)
      @submission.source_files.first.update_attributes!(code: submission_file("NoCompile.java"))

      @submission.execute_code!
      @submission.reload
    end

    its(:output) { should_not be_blank }
  end

  describe "errors" do
    describe "compilation issues" do
      before do
        # This file is understood by no language; compile errors in C, C++, and Java
        @submission.source_files.first.update_attributes!(code: submission_file("NoCompile.java"))
      end

      describe "java" do
        before do
          course.update_attributes(language: :java)

          @submission.execute_code!
          @submission.reload
        end

        its(:output) { should_not include("NoClassDefFoundError") }
      end

      describe "c" do
        before do
          course.update_attributes(language: :c)

          @submission.execute_code!
          @submission.reload
        end

        its(:output) { should_not include("./a.out: No such file or directory") }
      end

      describe "c++" do
        before do
          course.update_attributes(language: :cpp)

          @submission.execute_code!
          @submission.reload
        end

        its(:output) { should_not include("./a.out: No such file or directory") }
      end
    end
  end

  describe "main_file" do
    before do
      FactoryGirl.create(:source_file, submission: @submission, main: false)
    end

    its(:main_file) { should eq @submission.source_files.first }
  end

  describe "shell escaping input" do
    before do
      assignment.update_attributes(input: "foo | echo bar")
      @submission.source_files.first.update_attributes(
      code: submission_file('input_repeater.rb'))

      @submission.execute_code!
      @submission.reload
    end

    its(:output) { should eq "foo | echo bar\n" }
  end

  describe "ignore carriage returns" do
    before do
      assignment.update_attributes(expected_output: "Hello,\r world!")

      @submission.execute_code!
      @submission.reload
    end

    its(:status) { should be_correct }
  end

  describe "ignore trailing line whitespace" do
    before do
      course.update_attributes(language: :java)
      assignment.update_attributes(
        input: "Hello\nHi again\nGoodbye",

        # note extra spaces at end of lines
        expected_output: "Hello \nHi again \nGoodbye"
      )

      @submission.source_files.first.update_attributes(code: submission_file('JOptionPaneReader.java'))

      @submission.execute_code!
      @submission.reload
    end

    its(:status) { should be_correct }
  end

  describe "java packages" do
    before do
      course.update_attributes(language: :java)
      @submission.source_files.first.update_attributes(
      code: submission_file('JavaPackage.java'))

      @submission.execute_code!
      @submission.reload
    end

    its(:output) { should eq "Hello, world!\n" }
  end

  describe "using JOptionPane" do
    before do
      course.update_attributes(language: :java)
      assignment.update_attributes(input: "hello\n\\0\nhello again")
      @submission.source_files.first.update_attributes(code: submission_file("JOptionPaneReader.java"))

      @submission.execute_code!
      @submission.reload
    end

    its(:output) { should eq "hello\nnull\nhello again\n" }
  end

  describe "validation for correct UTF8" do
    before do
      @submission.source_files.first.update_attributes(
        code: submission_file("HasBadUtf8.class"))
    end

    it { should_not be_valid }
    it "this is a test" do
      @submission.save
      expect(@submission.errors[:source_files]).to include(course.language.bad_filetype_message)
    end
  end

  # I'm going to cheat and test private methods here.
  describe "activities" do
    it "notifies the teacher on submission creation" do
      activity = @submission.send(:create_activity_for_create)

      expect(activity.user).to eq teacher
    end

    it "notifies the teacher on submission update" do
      activity = @submission.send(:create_activity_for_update)

      expect(activity.user).to eq teacher
    end

    it "notifies the student on submission grade" do
      activity = @submission.send(:create_activity_for_grade)

      expect(activity.user).to eq student
    end
  end

  describe "#handle_create" do
    it "initializes num_attempts and executes code" do
      @submission.handle_create!
      @submission.reload

      expect(@submission.num_attempts).to eq 1
      expect(@submission.output).not_to be_empty
    end

    it "sets last_graded_at and last_submitted_at to now" do
      Timecop.freeze do
        @submission.handle_create!

        expect(@submission.reload.last_submitted_at.to_f).to be_within(0.01).of(
          Time.current.to_f)
      end
    end
  end

  describe "#handle_update" do
    it "increments num_attempts and executes code" do
      # first need to initialize
      assignment.update_attributes(expected_output: "Hello, world!")
      @submission.handle_create!
      @submission.reload

      # just a check that the submissions starts off correct
      expect(@submission.status).to be_correct

      old_num_attempts = @submission.num_attempts

      # The submission should now be wrong
      @submission.source_files.first.update_attributes(code:
        submission_file("norepeat.rb"))
      @submission.handle_update!
      @submission.reload

      expect(@submission.num_attempts - old_num_attempts).to eq 1
      expect(@submission.status).to be_incorrect
    end

    it "resets last_submitted_at" do
      @submission.handle_create!

      Timecop.freeze do
        @submission.handle_update!
        expect(@submission.reload.last_submitted_at.to_f).to be_within(0.01).of(
          Time.current.to_f)
      end
    end
  end

  describe "#handle_grade" do
    it "resets last_graded_at" do
      Timecop.freeze do
        @submission.handle_grade!
        expect(@submission.reload.last_graded_at.to_f).to be_within(0.01).of(
          Time.current.to_f)
      end
    end
  end

  describe "#has_outdated_grade?" do
    it "returns true if last_submitted_at is later than last_graded_at" do
      @submission.last_graded_at = 3.days.ago
      @submission.last_submitted_at = 2.days.ago

      expect(@submission).to have_outdated_grade
    end

    it "returns false if last_graded_at is more recent" do
      @submission.last_graded_at = 2.days.ago
      @submission.last_submitted_at = 3.days.ago

      expect(@submission).not_to have_outdated_grade
    end

    it "returns false if the submission hasn't been graded" do
      @submission.last_graded_at = nil
      @submission.last_submitted_at = 3.days.ago

      expect(@submission).not_to have_outdated_grade
    end
  end

  describe "assignments that skip tests" do
    it "skips tests if an assignment has should_run_tests: false" do
      assignment.should_run_tests = false
      assignment.save

      @submission.execute_code!
      @submission.reload

      expect(@submission.status).to be_not_tested
    end
  end
end
