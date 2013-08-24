FactoryGirl.define do
  factory :user, aliases: [:teacher, :student] do
    name { Faker::Name.name }
    sequence(:email) { |i| "user#{i}@example.com" }
    password "password"
    password_confirmation "password"

    factory :admin do
      admin true
    end
  end

  factory :course do
    sequence(:name) { |i| "Course #{i}" }
    description { Faker::Lorem.paragraph(10) }

    students do
      rand(2..10).times.map do
        FactoryGirl.create(:student)
      end
    end
  end

  factory :assignment do
    sequence(:name) { |i| "Assignment #{i}" }
    description { Faker::Lorem.paragraph(3) }
    due_time 1.day.from_now
    point_value { rand(5..10) }
    expected_output { Faker::Lorem.sentence(5) }
  end

  factory :submission do
    source_code File.new(Rails.root + 'spec/example_files/valid.rb')
  end

  factory :comment do
    content { Faker::Lorem.paragraph(3) }
  end
end
