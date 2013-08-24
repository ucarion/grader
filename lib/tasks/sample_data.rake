require 'factory_girl'

namespace :db do
  desc "Fill database with fake users"
  task populate: :environment do
    require File.expand_path("spec/factories.rb")

    puts "Creating admin"
    admin = FactoryGirl.create(:user, admin: true, email: "admin@example.com")

    puts "Creating users"
    20.times { FactoryGirl.create(:user) }

    puts "Creating courses"
    10.times { FactoryGirl.create(:course, teacher: admin) }

    puts "Creating assignments for the courses"
    admin.taught_courses.each do |course|
      10.times { FactoryGirl.create(:assignment, course: course) }
    end

    puts "Making people join the courses"
    User.all.each do |user|
      Course.all.each { |course| course.students << user } unless user == admin
    end

    course = Course.first

    puts "Having each student submit to the first assignment"
    course.students.each do |student|
      FactoryGirl.create(:submission, author: student, assignment: course.assignments.first).delay.execute_code!
    end

    puts "Having each student comment on their submission"
    course.students.each do |student|
      FactoryGirl.create(:comment, user: student, submission: student.submissions.first)
    end
  end
end
