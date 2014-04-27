namespace :backup do
  # Restore using a command to the effect of:
  #
  #   pg_restore --create -U grader -h localhost <dumpfile.sql>
  #
  # You may need to export PGPASSWORD=thepassword first.
  task :db do
    path_to_dump = '/dumps/db-dump-' + Time.now.strftime('%y.%m.%d.%H.%M') + '.sql'

    config = Rails.configuration.database_configuration[Rails.env]
    database = config['database']
    user = config['username']
    password = config['password']

    cmd = "export PGPASSWORD=#{password}\n" +
      "pg_dump #{config['database']} -U #{user} -h localhost -F c > #{path_to_dump}"

    system(cmd)

    backup_to_s3('db-dump', path_to_dump)
  end

  task :submissions do
    path_to_dump = "/dumps/submission-dump-#{Time.now.strftime('%y.%m.%d.%H.%M')}.tar.gz"

    path_to_submissions = Rails.root.join('public', 'system', 'source_files')

    # Tar the submissions ...
    `tar czf #{path_to_dump} #{path_to_submissions}`

    backup_to_s3('submission-dump', path_to_dump)
  end

  # If called as:
  #
  #   backup_to_s3('toto', '/foo/bar/baz.txt')
  #
  # Then the contents of /foo/bar/baz.txt will be saved in the S3 bucket at the
  # location:
  #
  #   toto/baz.txt
  def backup_to_s3(dir_name, file_path)
    connection = Fog::Storage.new(
      provider: 'AWS',
      aws_access_key_id: Figaro.env.aws_access_key,
      aws_secret_access_key: Figaro.env.aws_secret_access_key
    )

    bucket_name = Figaro.env.aws_source_files_backup_bucket
    bucket = connection.directories.get(bucket_name)

    bucket.files.create(
      key: "#{dir_name}/#{File.basename(file_path)}",
      body: File.read(file_path)
    )
  end
end
