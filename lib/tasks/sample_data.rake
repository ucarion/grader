namespace :db do
  desc "Fill database with fake users"
  task populate: :environment do
    puts "Creating admin"
    User.create!(name: Faker::Name.name, email: "admin@example.com", 
      password: "password", password_confirmation: "password", admin: true)

    puts "Creating users"
    100.times do |n|
      User.create!(name: Faker::Name.name, email: "#{n}@example.com", 
        password: "password", password_confirmation: "password")
    end

    puts "Creating courses"
    u = User.first
    10.times do |n|
      u.taught_courses.create!(name: "Example Course #{n}")
    end

    puts "Making people join the courses"
    User.all.each do |user|
      u.taught_courses.each do |course|
        course.students << user
      end
    end
  end
end
