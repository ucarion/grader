FactoryGirl.define do
  factory :user, aliases: [:student] do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    sequence(:email) { |i| "user#{i}@example.com" }
    password "password"
    password_confirmation "password"

    factory :admin do
      admin true
    end

    factory :teacher do
      teacher true
    end
  end

  factory :course do
    sequence(:name) { |i| "Course #{i}" }
    description { Faker::Lorem.paragraph(10) }
    language :ruby
    sequence(:enroll_key) { |i| "enroll_key_#{i}"}

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
    max_attempts { rand(1..4) }
    grace_period { 0 }
  end

  factory :submission do
    factory :submission_with_grade do
      grade { rand(5..10) }
    end

    status :waiting

    after(:build) do |submission, evaluator|
      submission.source_files << FactoryGirl.create_list(:source_file, 1, submission: nil)
    end
  end

  factory :source_file do
    main { true }
    code { File.new(Rails.root + 'spec/example_files/valid.rb') }
  end

  factory :comment do
    content { Faker::Lorem.paragraph(3) }
  end

  factory :activity do
    sequence(:name) { |i| "Activity #{i}" }
  end
end
