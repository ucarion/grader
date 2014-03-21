require 'spec_helper'

describe "AssignmentPages" do
  subject { page }

  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }

  before { sign_in teacher }

  describe "assignment show page" do
    let(:assignment) { FactoryGirl.create(:assignment, course: course) }

    before { visit assignment_path(assignment) }

    it { should have_content(assignment.name) }
    it { should have_content(assignment.description) }
    it { should have_content(course.name) }
    it { should have_link('Edit', href: edit_assignment_path(assignment)) }

    describe "time status" do
      describe "for closed assignments" do
        before do
          assignment.update_attributes(due_time: 1.year.ago)
          visit(current_path) # refresh
        end

        it { should have_selector('.timestatus.timestatus-closed') }
      end

      describe "for open assignments" do
        before do
          assignment.update_attributes(due_time: 1.year.from_now)
          visit(current_path) # refresh
        end

        it { should have_selector('.timestatus.timestatus-open') }
      end
    end

    let(:delete_button) { "Delete" }

    describe "for non-teacher users" do
      let!(:user) { FactoryGirl.create(:user) }

      before do
        sign_in user
        visit(assignment_path(assignment))
      end

      it { should_not have_link('Edit', href: edit_assignment_path(assignment)) }
      it { should_not have_link(delete_button) }
    end

    describe "for teacher users" do
      before do
        sign_in teacher
        visit assignment_path(assignment)
      end

      it { should have_link(delete_button) }

      it "should delete the course upon clicking the delete button" do
        expect { click_link delete_button }.to change(Assignment, :count).by(-1)
      end
    end

    describe "view or create submission button" do
      describe "for teachers" do
        before do
          sign_in teacher
          visit assignment_path(assignment)
        end

        it { should have_link("", href: assignment_submissions_path(assignment)) }
      end

      describe "for students" do
        let(:student) { FactoryGirl.create(:student) }

        before do
          sign_in student
          visit assignment_path(assignment)
        end

        it { should_not have_link("", href: assignment_submissions_path(assignment)) }

        describe "who are not enrolled in the course" do
          it { should_not have_link("", href: new_assignment_submission_path(assignment)) }
        end

        describe "who have not submitted to the assignment" do
          before do
            course.students << student
            visit current_path # refesh
          end

          it { should have_link("", href: new_assignment_submission_path(assignment)) }

          describe "but the assignment is closed" do
            before do
              assignment.update_attributes!(due_time: 1.day.ago)
              visit current_path
            end

            it { should_not have_link("", href: new_assignment_submission_path(assignment)) }
          end
        end

        describe "who have submitted to the assignment" do
          let!(:submission) { FactoryGirl.create(:submission, author: student, assignment: assignment) }

          before do
            course.students << student
            visit current_path
          end

          it { should have_link("", href: submission_path(submission)) }
        end
      end
    end

    describe "plagiarism information" do
      describe "for teachers" do
        before do
          sign_in teacher
          visit assignment_path(assignment)
        end

        it { should have_link "Plagiarism", plagiarism_assignment_path(assignment) }
      end

      describe "for non-teachers" do
        before do
          sign_out
          visit assignment_path(assignment)
        end

        it { should_not have_link "Plagiarism", plagiarism_assignment_path(assignment) }
      end
    end

    describe "for signed out users" do
      before do
        sign_out
        visit assignment_path(assignment)
      end

      it "should not crash on rendering page" do
        expect(page).to have_content assignment.name
      end
    end
  end

  describe "assignment creation page" do
    let(:submit) { "Create Assignment" }

    before { visit new_course_assignment_path(course) }

    it { should have_title("Create a new assignment") }

    describe "submitted with bad information" do
      it "should not create an assignment on submission" do
        expect { click_button submit }.not_to change(Assignment, :count)
      end
    end

    describe "submitted with good information" do
      before do
        fill_in "Name", with: "Course"
        fill_in "Description", with: "Description goes here ..."
        fill_in "Input", with: "a b c d e"
        fill_in "Expected output", with: "Output goes here ..."
        fill_in "Due time", with: 1.year.from_now.strftime("%m/%d/%Y")
        fill_in "Point value", with: "10"
      end

      it "should create a new assignment on click" do
        expect { click_button submit }.to change(Assignment, :count).by(1)
      end

      it "creates a new activity for each student" do
        puts course.students.count
        expect do
          click_button submit
        end.to change(Activity, :count).by(course.students.count)
      end

      describe "after submitting" do
        before { click_button submit }

        it { should have_title course.name }
        it { should have_selector('.alert.alert-success', text: "Assignment") }
      end
    end
  end

  describe "assignment editing page" do
    let(:assignment) { FactoryGirl.create(:assignment, course: course) }
    let(:submit) { "Submit Changes" }

    before { visit edit_assignment_path(assignment) }

    it { should have_title('Edit Assignment') }

    describe "given bad information" do
      before do
        fill_in "Name", with: ""
        click_button submit
      end

      it { should have_selector('.alert.alert-danger') }
      it { should have_title('Edit Assignment') }
    end

    describe "given good information" do
      before { click_button submit }

      it { should have_selector('.alert.alert-success') }
    end
  end

  describe "assignment plagiarism page" do
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course, teacher: teacher) }
    let(:assignment) { FactoryGirl.create(:assignment, course: course) }
    let(:student1) { FactoryGirl.create(:student) }
    let(:student2) { FactoryGirl.create(:student) }
    let(:student3) { FactoryGirl.create(:student) }

    before do
      course.students << student1
      course.students << student2

      # TODO do this in a less yucky fashion -- skip the source-file creation callback?
      cheat1 = FactoryGirl.create(:submission, assignment: assignment, author: student1)
      cheat1.source_files.clear
      FactoryGirl.create(:source_file, code: submission_file("prime/doppel.rb"), submission: cheat1)

      cheat2 = FactoryGirl.create(:submission, assignment: assignment, author: student2)
      cheat2.source_files.clear
      FactoryGirl.create(:source_file, code: submission_file("prime/ganger.rb"), submission: cheat2)

      cheat3 = FactoryGirl.create(:submission, assignment: assignment, author: student3)
      cheat3.source_files.clear
      FactoryGirl.create(:source_file, code: submission_file("prime/original.rb"), submission: cheat3)
    end

    describe "viewed by a non-teacher" do
      before do
        sign_in student1
        visit plagiarism_assignment_path(assignment)
      end

      it { should have_selector('.alert.alert-danger') }
    end

    describe "viewed by the teacher" do
      before do
        sign_in teacher
        visit plagiarism_assignment_path(assignment)
      end

      it { should have_content("Plagiarism for #{assignment.name}") }

      # TODO: Test to see that the plagiarised ones are highlighted
      it "should list each submission and what it copied from" do
        assignment.submissions.each do |submission|
          expect(page).to have_content(submission.author.name)
        end
      end
    end

    # Maybe this should get its own context outside of plagiarism?
    # I'd like to re-use this gigantic before block here, though ...
    describe "submission comparison" do
      let(:submission1) { student1.submissions.first }
      let(:submission2) { student2.submissions.first }

      describe "comparing with a submission that doesn't belong to the assignment" do
        before do
          other_student = FactoryGirl.create(:student)
          course.students << other_student

          other_assignment = FactoryGirl.create(:assignment, course: course)

          other_submission = FactoryGirl.create(:submission, assignment: other_assignment, author: other_student)

          sign_in teacher
          visit compare_assignment_path(assignment, submission1, other_submission)
        end

        it { should have_selector('.alert.alert-danger') }
      end

      describe "visited by a non-teacher" do
        before do
          sign_in student1
          visit compare_assignment_path(assignment, submission1, submission2)
        end

        it { should have_selector('.alert.alert-danger') }
      end

      describe "visited by the teacher" do
        let(:sub1_source) { File.read(submission1.main_file.code.path) }
        let(:sub2_source) { File.read(submission2.main_file.code.path) }

        before do
          sign_in teacher
          visit compare_assignment_path(assignment, submission1, submission2)
        end

        it { should have_content("Comparison") }

        describe "source file contents" do
          it { should have_content(sub1_source) }
          it { should have_content(sub2_source) }
        end

        describe "diff" do
          # testing for the exact contents of the diff is pointless and
          # complicated due to HTML escaping issues. The goal here isn't to test
          # Diffy, it's to test my code.
          it { should have_selector('.diff') }
        end
      end
    end
  end
end
