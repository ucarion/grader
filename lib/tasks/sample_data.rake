namespace :db do
  desc "Fill database with fake users"
  task populate: :environment do
    puts "Creating admin"
    admin_user = FactoryGirl.create(:admin, email: "admin@example.com")

    puts "Creating users"
    20.times { FactoryGirl.create(:user) }

    puts "Creating courses"
    10.times { FactoryGirl.create(:empty_course, teacher: admin_user) }

    puts "Creating assignments for the courses"
    admin_user.taught_courses.each do |course|
      10.times { FactoryGirl.create(:assignment, course: course, expected_output: "Hello, world!") }
    end

    puts "Making people join the courses"
    User.all.each do |user|
      Course.all.each { |course| course.students << user } unless user == admin_user
    end

    course = Course.first

    puts "Having each student submit to each assignment"
    course.students.each do |student|
      course.assignments.each do |assignment|
        FactoryGirl.create(:submission_with_grade, author: student, assignment: assignment)
      end
    end

    puts "Evaluating the first assignment's submissions"
    course.assignments.first.submissions.each do |submission|
      submission.execute_code!
    end

    puts "Having each student comment on their first submission"
    course.students.each do |student|
      FactoryGirl.create(:comment, user: student, submission: student.submissions.first)
    end
  end
end
