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
    language :ruby

    students do
      rand(2..10).times.map do
        FactoryGirl.create(:student)
      end
    end

    factory :empty_course do
      students { [] }
    end
  end

  factory :assignment do
    sequence(:name) { |i| "Assignment #{i}" }
    description { Faker::Lorem.paragraph(3) }
    due_time 1.day.from_now
    point_value { rand(5..10) }
    expected_output { Faker::Lorem.sentence(5) }
    input { Faker::Lorem.sentence(2) }
  end

  factory :submission do
    source_code File.new(Rails.root + 'spec/example_files/valid.rb')

    factory :submission_with_grade do
      grade { rand(5..10) }
    end
  end

  factory :comment do
    content { Faker::Lorem.paragraph(3) }
  end
end
