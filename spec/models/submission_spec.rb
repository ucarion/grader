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
    before { @submission.execute_code! }

    its(:output) { should eq "Hello, world!\n" }
  end

  describe "input" do
    before do
      @submission.source_files.first.update_attributes(code: File.new(Rails.root + 'spec/example_files/inreader.rb'))

      @submission.execute_code!
    end

    its(:output) { should eq "[1, 4, 9, 16, 25]\n" }
  end

  describe "status" do
    describe "before being executed" do
      its(:status) { should eq Submission::Status::WAITING }
    end

    describe "after being executed" do
      describe "and the output is the expected output" do
        before do
          assignment.update_attributes(expected_output: "Hello, world!")
          @submission.execute_code!
        end

        its(:status) { should eq Submission::Status::OUTPUT_CORRECT }
      end

      describe "and the output is not the expected output" do
        before do
          assignment.update_attributes(expected_output: "Something else")
          @submission.execute_code!
        end

        its(:status) { should eq Submission::Status::OUTPUT_INCORRECT }
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
    end

    its(:output) { should eq "Hello, there!\n" }
  end

  describe "programming languages" do
    describe "java" do
      before do
        course.update_attributes!(language: :java)
        @submission.source_files.first.update_attributes!(code: submission_file("JavaExample.java"))

        @submission.execute_code!
      end

      its(:output) { should eq "1\n4\n9\n16\n25\n" }
    end

    describe "c" do
      before do
        course.update_attributes!(language: :c)
        @submission.source_files.first.update_attributes!(code: submission_file("c_example.c"))

        @submission.execute_code!
      end

      its(:output) { should eq "1\n4\n9\n16\n25\n" }
    end

    describe "c++" do
      before do
        course.update_attributes(language: :cpp)
        @submission.source_files.first.update_attributes!(code: submission_file("cpp_example.cpp"))

        @submission.execute_code!
      end

      its(:output) { should eq "1\n4\n9\n16\n25\n" }
    end

    describe "python" do
      before do
        course.update_attributes(language: :python)
        @submission.source_files.first.update_attributes!(code: submission_file("pyexample.py"))

        @submission.execute_code!
      end

      its(:output) { should eq "1\n4\n9\n16\n25\n" }
    end
  end

  describe "stderr" do
    before do
      course.update_attributes(language: :java)
      @submission.source_files.first.update_attributes!(code: submission_file("NoCompile.java"))

      @submission.execute_code!
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
        end

        its(:output) { should_not include("NoClassDefFoundError") }
      end

      describe "c" do
        before do
          course.update_attributes(language: :c)

          @submission.execute_code!
        end

        its(:output) { should_not include("./a.out: No such file or directory") }
      end

      describe "c++" do
        before do
          course.update_attributes(language: :cpp)

          @submission.execute_code!
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
end
