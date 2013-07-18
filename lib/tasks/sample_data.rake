namespace :db do
  desc "Fill database with fake users"
  task populate: :environment do
    100.times do |n|
      User.create!(name: Faker::Name.name, email: "#{n}@example.com", 
        password: "password", password_confirmation: "password")
    end
  end
end
