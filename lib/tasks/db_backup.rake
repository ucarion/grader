namespace :db do

  # Restore using a command to the effect of:
  #
  #   pg_restore --create -U grader -h localhost <dumpfile.sql>
  #
  # You may need to export PGPASSWORD=thepassword first.
  task :backup do
    path_to_dump = '/dumps/dump-' + Time.now.strftime('%y.%m.%d.%H.%M') + '.sql'

    config = Rails.configuration.database_configuration[Rails.env]
    database = config['database']
    user = config['username']
    password = config['password']

    cmd = "export PGPASSWORD=#{password}\n" +
      "pg_dump #{config['database']} -U #{user} -h localhost -F c > #{path_to_dump}"

    system cmd
  end
end
