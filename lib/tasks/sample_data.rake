namespace :db do
  desc "Fill database with fake users"
  task populate: :environment do
    puts "Creating admin"
    User.create!(name: Faker::Name.name, email: "admin@example.com", 
      password: "password", password_confirmation: "password", admin: true)

    puts "Creating users"
    50.times do |n|
      User.create!(name: Faker::Name.name, email: "#{n}@example.com", 
        password: "password", password_confirmation: "password")
    end

    puts "Creating courses"
    u = User.first
    10.times do |n|
      u.taught_courses.create!(name: "Course #{n}", description: Faker::Lorem.paragraph(3))
    end

    puts "Creating assignments for the courses"
    Course.first.assignments.create!(name: "Example Assignment", 
      description: Faker::Lorem.paragraph(3), due_time: 1.day.from_now)

    u.taught_courses.each_with_index do |course|
      5.times do |n|
        course.assignments.create!(name: "Assignment #{n}", 
          description: Faker::Lorem.paragraph(3), due_time: rand(-3..3).days.from_now)
      end
    end

    puts "Making people join the courses"
    User.all.each do |user|
      u.taught_courses.each do |course|
        course.students << user
      end
    end

    puts "Having each student submit to the first assignment"
    a = Assignment.first
    User.all.each do |user|
      a.submissions.create!(author: user, source_code: File.new(Rails.root + 'spec/example_files/valid.rb'))
    end
  end
end
