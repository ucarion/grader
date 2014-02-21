require 'spec_helper'

describe "CoursePages" do
  subject { page }

  describe "course creation page" do
    before do
      sign_in(FactoryGirl.create(:user))
      visit new_course_path
    end

    let(:submit) { "Create Course" }

    it { should have_title('Create new course') }

    describe "given invalid information" do
      it "should not create a course on submission" do
        expect { click_button submit }.not_to change(Course, :count)
      end
    end

    describe "given valid information" do
      before do
        fill_in "Name", with: "Example"
        fill_in "Description", with: "Text goes here ..."
      end

      it "should create a new course on submission" do
        expect { click_button submit }.to change(Course, :count).by(1)
      end

      describe "after creating the course" do
        before { click_button submit }

        it { should have_title("Example") }
        it { should have_selector('div.alert.alert-success', text: "Course") }
      end
    end
  end

  describe "course description page" do
    let(:teacher) { FactoryGirl.create(:user) }
    let(:user) { FactoryGirl.create(:user) }
    let(:course) { teacher.taught_courses.create!(name: "Test", description: "Class", language: :ruby) }

    describe "when there are no assignments for that course" do
      before { visit course_path(course) }

      it { should have_content("There are no assignments for this course.") }
    end

    describe "when there are assignments for that course" do
      before do
        10.times do
          FactoryGirl.create(:assignment, course: course)
        end

        visit course_path(course)
      end

      it "should display all assignments" do
        course.assignments.find_all do |assignment|
          expect(page).to have_content(assignment.name)
          expect(page).to have_content(assignment.description)
        end
      end

      describe "and those assignments have ungraded submissions" do
        before do
          6.times do
            student = FactoryGirl.create(:student)
            course.students << student
            FactoryGirl.create(:submission, author: student,
              assignment: course.assignments.first)
          end

          visit current_path
        end

        it "shows that there are ungraded submissions" do
          expect(find('span.badge').text).to eq '6'
        end
      end
    end

    describe "when there are no enrolled students" do
      before { visit course_path(course) }

      it { should have_content("There are no students enrolled in this class.") }
      it { should_not have_selector('.list-users-table') }
    end

    describe "when there are enrolled students" do
      before do
        10.times do
          course.students << FactoryGirl.create(:student)
        end

        visit course_path(course)
      end

      it "should have all the students listed" do
        course.students.each do |student|
          expect(page).to have_selector('td', text: student.name)
        end
      end
    end

    describe "joining a class" do
      describe "when not logged in" do
        before { visit course_path(course) }

        it { should_not have_selector('.btn-enroll') }
      end

      describe "when logged in" do
        before do
          sign_in user
          visit course_path(course)
        end

        it { should have_selector('.btn-enroll') }

        describe "clicking on the enroll button" do
          before { click_link 'Enroll' }

          it "should make the current user enroll into the course" do
            expect(user.enrolled_courses).to include(course)
            expect(course.students).to include(user)
          end

          describe "after having already enrolled" do
            it { should_not have_selector('.btn-enroll') }
          end
        end
      end

      describe "when logged in as the teacher of a course" do
        before do
          sign_in teacher
          visit course_path(course)
        end

        it { should_not have_selector('.btn-enroll') }
      end

      describe "when logged in as a student enrolled in a course" do
        let(:student) { FactoryGirl.create(:student) }

        before do
          course.students << student

          sign_in student
          visit course_path(course)
        end

        it { should_not have_selector('.btn-enroll') }
      end
    end

    describe "when deleting a course" do
      let(:delete_button) { "Delete Course" }

      describe "when not the teacher of the course" do
        before do
          sign_in user

          visit course_path(course)
        end

        it { should_not have_link delete_button }
      end

      describe "when the teacher of the course" do
        before do
          sign_in teacher

          visit course_path(course)
        end

        it { should have_link delete_button }

        it "should delete the course when clicking the delete button" do
          expect { click_link delete_button }.to change(Course, :count).by(-1)
        end
      end
    end

    describe "analytics button" do
      describe "when signed in as the teacher" do
        before do
          sign_in teacher

          visit course_path(course)
        end

        it { should have_link("", href: analytics_course_path(course)) }
      end

      describe "when not the teacher" do
        before do
          sign_in user

          visit course_path(course)
        end

        it { should_not have_link("", href: analytics_course_path(course)) }
      end
    end
  end

  describe "edit course page" do
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course, teacher: teacher) }
    let(:submit) { "Submit changes" }

    before do
      sign_in teacher
      visit edit_course_path(course)
    end

    describe "submitted with bad information" do
      before do
        fill_in "Name", with: ""
        click_button submit
      end

      it { should have_content('error') }
      it { should have_title('Edit Course') }
    end

    describe "submitted with valid information" do
      before { click_button submit }

      it { should have_selector('.alert-success') }
    end
  end

  describe "course analytics page" do
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course, teacher: teacher) }
    let(:student) { FactoryGirl.create(:student) }

    before do
      course.students << student

      5.times do |n|
        assignment = FactoryGirl.create(:assignment, course: course)
        FactoryGirl.create(:submission_with_grade, author: student, assignment: assignment)
      end
    end

    describe "as a teacher" do
      before do
        sign_in teacher

        visit analytics_course_path(course)
      end

      it { should have_content("Analytics for #{course.name}") }
      it { should have_title("#{course.name} Analytics")}

      describe "overall grade average" do
        let(:grade) { "#{student.grade_in_course(course)} / #{course.total_points}" }

        it { should have_content(grade) }
      end
    end
  end

  describe "enrollment page" do
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:student) { FactoryGirl.create(:student) }
    let(:course) { FactoryGirl.create(:course, teacher: teacher) }

    before do
      sign_in student
      visit enroll_course_path
    end

    it { should have_title('Enroll') }

    describe "filled in with a course's key" do
      before do
        fill_in "Enroll key", with: course.enroll_key
        click_button "Enroll"
      end

      it "enrolls the student" do
        expect(course.students).to include(student)
      end

      it "redirects to the course's path" do
        expect(current_url).to eq course_url(course)
      end
    end

    describe "filled in with an invalid key" do
      before do
        click_button "Enroll"
      end

      it "does not enroll the student in anything" do
        expect(student.enrolled_courses).to be_empty
      end

      it "reports no course was found" do
        expect(page).to have_content('no course with that key')
      end
    end
  end
end
