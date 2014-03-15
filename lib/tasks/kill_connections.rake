namespace :db do
  task :kill_postgres_connections => :environment do
    db_name = "grader_#{Rails.env}"
    sh = <<-EOF
      ps xa \
        | grep postgres: \
        | grep #{db_name} \
        | grep -v grep \
        | awk '{print $1}' \
        | xargs sudo kill
    EOF

    puts `#{sh}`
  end
end
