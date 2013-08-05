require 'spec_helper'

describe "SubmissionsPages" do
  subject { page }

  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course) }
  let(:student) { FactoryGirl.create(:student) }

  describe "show page" do
    let(:submission) do
      student.submissions.create!(assignment: assignment,
        source_code: File.new(Rails.root + 'spec/example_files/valid.rb'))
    end

    before { visit submission_path(submission) }

    it { should have_content(student.name) }
    it { should have_content(assignment.name) }

    it "should show the submission's source code" do
      source = File.read(submission.source_code.path)
      expect(page).to have_content(source)
    end
  end

  describe "creation page" do
    let(:submit) { "Create Submission" }

    before do
      assignment.save!
      course.students << student
      sign_in student

      visit new_assignment_submission_path(assignment)
    end

    it { should have_title("Create a new Submission") }

    describe "submitted with good information" do
      before { attach_file "Source code", Rails.root + 'spec/example_files/valid.rb' }

      it "should create a new submission on submit" do
        expect { click_button submit }.to change(Submission, :count).by(1)
      end

      describe "after submitting" do
        before { click_button submit }

        it { should have_selector('.alert.alert-success', text: "submission") }
      end
    end

    describe "submitted with bad information" do
      before { click_button submit }

      it { should have_selector('.alert.alert-error') }
    end

    describe "for an assignment that is closed" do
      before do
        assignment.update_attributes(due_time: 1.day.ago)

        visit new_assignment_submission_path(assignment)
      end

      it { should have_selector('.alert', text: "closed") }
    end

    describe "visited while not signed in" do
      before do
        sign_out

        visit new_assignment_submission_path(assignment)
      end

      it { should have_title("Sign in") }
    end

    describe "visited by a user who is not enrolled in the corresponding course" do
      let(:other_user) { FactoryGirl.create(:user) }

      before do
        sign_in other_user

        visit new_assignment_submission_path(assignment)
      end

      it { should have_selector('.alert', text: "cannot post submissions for this course") }
    end
  end
end
