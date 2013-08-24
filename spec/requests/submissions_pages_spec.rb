require 'spec_helper'

describe "SubmissionsPages" do
  subject { page }

  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course) }
  let(:student) { FactoryGirl.create(:student) }

  before do
    course.students << student
  end

  describe "show page" do
    let(:submission) do
      student.submissions.create!(assignment: assignment,
        source_code: File.new(Rails.root + 'spec/example_files/norepeat.rb'))
    end

    before do
      sign_in student
      visit submission_path(submission)
    end

    it { should have_link(student.name, href: user_path(student)) }
    it { should have_link(assignment.name, href: assignment_path(assignment)) }

    it "should show the submission's source code" do
      source = File.read(submission.source_code.path)
      expect(page).to have_content(source)
    end

    describe "submission output" do
      describe "if not yet executed" do
        it { should have_content("This submission is still pending") }
      end

      describe "if executed" do
        before do
          submission.execute_code!
          visit current_path
        end

        it { should have_selector('.output', text: submission.output.strip) }
        it { should have_selector('.expected-output', text: assignment.expected_output) }
      end
    end

    describe "authentication" do
      describe "visited by someone who is not signed in" do
        before do
          sign_out
          visit submission_path(submission)
        end

        it { should have_title("Sign in") }
      end

      describe "visited by another user" do
        let(:other_user) { FactoryGirl.create(:user) }

        before do
          sign_in other_user
          visit submission_path(submission)
        end

        it { should have_selector('.alert', text: "others' submissions") }
      end

      describe "visited by the teacher" do
        before do
          sign_in teacher
          visit submission_path(submission)
        end

        it { should have_content(student.name) }
        it { should have_content(assignment.name) }
        it { should have_button("Submit") }

        it { should have_link("", href: assignment_submissions_path(assignment)) }
      end

      describe "visited by the author" do
        it { should_not have_button("Submit") }

        describe "when the submission is ungraded" do
          it { should have_content("has not been graded yet") }
        end

        describe "when the submission has been graded" do
          before do
            submission.update_attributes(grade: 10)
            visit current_path
          end

          it { should have_content(submission.grade) }
        end
      end
    end

    describe "comments" do
      before do
        3.times do
          FactoryGirl.create(:comment, user: teacher, submission: submission)
        end

        visit current_path
      end

      it "should have all the comments displayed" do
        submission.comments.each do |comment|
          expect(page).to have_content(comment.content)
        end
      end
    end

    describe "new comment form" do
      it { should have_selector('.btn-comment') }

      let(:submit_comment) { "Comment" }

      describe "filled in with invalid information" do
        before { click_button submit_comment }

        it { should have_selector('.alert.alert-error', text: "blank") }
      end

      describe "filled in with valid information" do
        before { fill_in "comment[content]", with: "Lorem ipsum dolor sit amet." }

        it "should create a new comment on submit" do
          expect { click_button submit_comment }.to change(submission.comments, :count).by(1)
        end

        describe "after commenting" do
          before { click_button submit_comment }

          it { should have_selector('.alert.alert-success', text: "created") }
        end
      end
    end

    describe "status" do
      describe "when a submission passed tests" do
        before do
          submission.update_attributes!(status: Submission::Status::OUTPUT_CORRECT)

          visit current_path
        end

        it { should have_content("submission passed tests") }
      end

      describe "when a submission failed tests" do
        before do
          submission.update_attributes!(status: Submission::Status::OUTPUT_INCORRECT)

          visit current_path
        end

        it { should have_content("submission failed tests") }
      end
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
      before { attach_file "Source code", Rails.root + 'spec/example_files/norepeat.rb' }

      it "should create a new submission on submit" do
        expect { click_button submit }.to change(Submission, :count).by(1)
      end

      describe "after submitting" do
        before { click_button submit }

        it { should have_selector('.alert.alert-success', text: "submission") }

        it "should automatically evaluate the program" do
          expect(page).to have_selector('.output')
        end
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

  describe "assignment submissions page" do
    let(:assignment) { FactoryGirl.create(:assignment, course: course) }

    before do
      5.times do |n|
        student = FactoryGirl.create(:student)
        course.students << student
        FactoryGirl.create(:submission, assignment: assignment, author: student, grade: n)
      end
    end

    describe "when visisted by a teacher" do
      before do
        sign_in teacher
        visit assignment_submissions_path(assignment)
      end

      it { should have_title("Submissions for #{assignment.name}") }

      it "should list each of the assignment's submissions' authors" do
        assignment.submissions.each do |submission|
          expect(page).to have_content(submission.author.name)
          expect(page).to have_content("#{submission.grade} / #{submission.assignment.point_value}")
        end
      end
    end

    describe "when visited by a non-teacher" do
      before do
        sign_in assignment.course.students.last # a student of the assignment
        visit assignment_submissions_path(assignment)
      end

      it { should have_selector('.alert', text: "cannot view")}
    end
  end
end
