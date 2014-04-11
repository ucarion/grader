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
    let(:submission) { FactoryGirl.create(:submission, author: student, assignment: assignment) }

    before do
      sign_in student
      visit submission_path(submission)
    end

    it { should have_link(student.name, href: user_path(student)) }
    it { should have_link(assignment.name, href: assignment_path(assignment)) }

    it "should show the submission's source code" do
      source = File.read(submission.source_files.first.code.path)
      expect(page).to have_content(source)
    end

    describe "with multiple files" do
      before do
        FactoryGirl.create(:source_file, submission: submission,
          code: submission_file("norepeat.rb"), main: false)
      end

      it "should show each source file" do
        submission.source_files.each do |file|
          source = File.read(file.code.path)

          expect(page).to have_content(source)
          expect(page).to have_selector('.source-file pre', text: source.strip)
          expect(page).to have_selector('.source-file', text: file.code_file_name)
        end
      end

      it "should mark the main file as being main" do
        main_file_name = submission.source_files.first.code_file_name
        expect(page).to have_selector('.source-file.main', text: main_file_name)
      end
    end

    describe "submission output" do
      describe "if not yet executed" do
        it { should have_content("Waiting") }
      end

      describe "if executed" do
        before do
          submission.execute_code!
          submission.reload
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

        it { should have_selector('.alert.alert-danger') }
      end

      describe "visited by another user" do
        let(:other_user) { FactoryGirl.create(:user) }

        before do
          sign_in other_user
          visit submission_path(submission)
        end

        it { should have_selector('.alert.alert-danger') }
      end

      describe "visited by the teacher" do
        before do
          sign_in teacher
          visit submission_path(submission)
        end

        it { should have_content(student.name) }
        it { should have_link("", href: assignment_submissions_path(assignment)) }
        it { should have_button("Submit") }

        it { should have_link("", href: assignment_submissions_path(assignment)) }

        describe "grade form" do
          before do
            fill_in 'Grade', with: 3
          end

          it "creates an activity for the student on submit" do
            expect { click_button "Submit" }.to change(Activity, :count).by(1)
          end
        end
      end

      describe "visited by the author" do
        it { should_not have_button("Submit") }

        describe "when the submission is ungraded" do
          it { should have_content("Ungraded") }
        end

        describe "when the submission has been graded" do
          before do
            submission.update_attributes(grade: 10)
            visit current_path
          end

          it { should have_content(submission.grade) }
        end
      end

      describe "visited after the assignment closes" do
        before do
          assignment.update_attributes(due_time: 1.day.ago)
          visit current_path
        end

        it { should_not have_link("Resubmit", href: edit_submission_path(submission)) }
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

        it { should have_selector('.alert.alert-danger', text: "blank") }
      end

      describe "filled in with valid information" do
        before { fill_in "comment[content]", with: "Lorem ipsum dolor sit amet." }

        it "should create a new comment on submit" do
          expect { click_button submit_comment }.to change(submission.comments, :count).by(1)
        end

        it "creates a new activity on submit" do
          expect { click_button submit_comment }.to change(Activity, :count).by(1)
        end

        describe "after commenting" do
          before { click_button submit_comment }

          it { should have_selector('.alert.alert-success', text: "created") }
        end
      end
    end

    describe "override max attempts form" do
      before do
        sign_in teacher
        visit submission_path(submission)
      end

      let(:override_btn) { "Override" }

      describe "filled in with invalid information" do
        before do
          fill_in "submission[max_attempts_override]", with: "nonsense"
          click_button override_btn
        end

        it { should have_selector('.alert.alert-danger') }
      end

      describe "filled in with valid information" do
        before do
          fill_in "submission[max_attempts_override]", with: "100"
          click_button override_btn
        end

        it { should have_selector('.alert.alert-success', text: 'updated') }
      end
    end

    describe "status" do
      describe "when a submission passed tests" do
        before do
          submission.update_attributes!(status: Submission::Status::OUTPUT_CORRECT)

          visit current_path
        end

        it { should have_selector('.label-success') }

        it "doesn't offer a diff between the expected and actual output" do
          expect(page).not_to have_selector('.diff-expected-actual-output')
        end
      end

      describe "when a submission failed tests" do
        before do
          submission.update_attributes!(
            status: Submission::Status::OUTPUT_INCORRECT,
            output: '')

          visit current_path
        end

        it { should have_selector('.label-danger') }

        it "offers a diff between the expected and actual output" do
          puts page.body
          expect(page).to have_selector('.diff-expected-actual-output')
        end
      end
    end

    describe "resubmission" do
      describe "for non-authors" do
        before do
          sign_in teacher
          visit submission_path(submission)
        end

        it { should_not have_link("", href: edit_submission_path(submission)) }
      end

      describe "for authors" do
        before do
          sign_in student
          visit submission_path(submission)
        end

        it { should have_link("Resubmit", href: edit_submission_path(submission)) }
      end
    end

    describe "deletion" do
      before do
        sign_in teacher
        visit submission_path(submission)
      end

      it "destroys the submission on click" do
        click_link "Delete this submission"
        expect { Submission.find(submission.id) }.to raise_error(ActiveRecord::RecordNotFound)
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
      before do
        attach_file "Code", Rails.root + 'spec/example_files/norepeat.rb'
        check "Main"
      end

      it "should create a new submission on submit" do
        expect { click_button submit }.to change(Submission, :count).by(1)
      end

      it "creates an activity for the teacher" do
        expect { click_button submit }.to change(Activity, :count).by(1)
      end

      describe "after submitting" do
        before { click_button submit }

        it { should have_selector('.alert.alert-success', text: "submission") }

        it "should automatically evaluate the program" do
          expect(page).to have_selector('.output')
        end

        it "sets the number of attempts to 1" do
          expect(page).to have_content("1 / #{assignment.max_attempts}")
        end
      end
    end

    describe "submitted with bad information" do
      before { click_button submit }

      it { should have_selector('.alert.alert-danger') }
    end

    describe "for an assignment that is closed" do
      before do
        assignment.update_attributes(due_time: 1.day.ago)

        visit new_assignment_submission_path(assignment)
      end

      it { should have_selector('.alert.alert-danger') }
    end

    describe "visited while not signed in" do
      before do
        sign_out

        visit new_assignment_submission_path(assignment)
      end

      it { should have_selector('.alert.alert-danger') }
    end

    describe "visited by a user who is not enrolled in the corresponding course" do
      let(:other_user) { FactoryGirl.create(:user) }

      before do
        sign_in other_user

        visit new_assignment_submission_path(assignment)
      end

      it { should have_selector('.alert.alert-danger') }
    end
  end

  describe "edit page" do
    let(:submission) { FactoryGirl.create(:submission, author: student, assignment: assignment) }

    describe "authentication" do
      before do
        sign_in teacher
        visit edit_submission_path(submission)
      end

      it { should have_selector('.alert.alert-danger') }
    end

    before do
      sign_in student
      visit edit_submission_path(submission)
    end

    it { should have_content("Retry Submission") }

    let(:submit) { "Resubmit Submission" }

    describe "visited after assignment is closed" do
      before do
        assignment.update_attributes(due_time: 1.day.ago)
        visit current_path
      end

      it { should have_selector('.alert.alert-danger') }
    end

    describe "filled in with correct information" do
      before do
        attach_file "Code", submission_file("norepeat.rb").path
      end

      describe "number of attempts" do
        it "should be incremented" do
          num_attempts_before = submission.num_attempts

          click_button submit
          submission.reload

          num_attempts_after = submission.num_attempts

          expect(num_attempts_after - num_attempts_before).to eq 1
        end
      end

      it "creates an activity for the teacher" do
        expect { click_button submit }.to change(Activity, :count).by(1)
      end

      describe "after submitting" do
        before do
          click_button submit

          submission.reload
        end

        it "should change the submission" do
          expect(submission.source_files.first.code_file_name).to eq "norepeat.rb"
        end

        describe "after submission" do
          it "should show the new submission's source code" do
            source = File.read(submission.source_files.first.code.path)
            expect(page).to have_content(source)
          end

          it "should show the new submission's output" do
            expect(page).to have_content("[0, 1, 4, 9, 16, 25]")
          end
        end
      end
    end
  end

  describe "assignment submissions page" do
    let(:assignment) { FactoryGirl.create(:assignment, course: course) }

    describe "when there are no submissions" do
      before do
        sign_in teacher
        visit assignment_submissions_path(assignment)
      end

      it { should have_content("no submissions") }
    end

    describe "when there are submissions" do
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

        it "lists submissions by given param's order" do
          visit assignment_submissions_path(assignment,
            sort: :author, order: :asc)
          ordered_by_name = assignment.submissions.sort_by { |s| s.author.name }

          first_user = ordered_by_name.first.author.name
          expect(page).to have_selector("tr:nth-child(2) a", text: first_user)

          second_user = ordered_by_name.second.author.name
          expect(page).to have_selector("tr:nth-child(3) a", text: second_user)
        end

        it "has links to sort submissions" do
          possible_params = [:author, :status, :grade].product([:asc, :desc])

          possible_params.each do |(key, direction)|
            expect(page).to have_link("", href: assignment_submissions_path(
              assignment, sort: key, order: direction))
          end
        end

        it "shows if a submission's grade is outdated" do
          submission = assignment.submissions.first

          submission.update_attributes(last_graded_at: 3.days.ago,
            last_submitted_at: 2.days.ago)

          visit current_path

          expect(page).to have_selector("i.grade-outdated")
        end
      end

      describe "when visited by a non-teacher" do
        before do
          sign_in assignment.course.students.last # a student of the assignment
          visit assignment_submissions_path(assignment)
        end

        it { should have_selector('.alert.alert-danger') }
      end
    end
  end
end
