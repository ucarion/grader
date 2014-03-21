set :application, 'grader'

set :pty, true

set :repo_url, "git@github.com:ulyssecarion/grader.git"
set :scm, "git"
set :scm_passphrase, ""
set :ssh_options, { forward_agent: true }

set :linked_dirs, %w{public/system}

before "deploy", "delayed_job:stop"
before "deploy", "docker:pull"

after "deploy", "deploy:restart"
after "deploy", "deploy:ping"
after "deploy", "delayed_job:start"

after "deploy", "deploy:check:write_permissions"
after "deploy", "deploy:check:docker_group"
after "deploy", "deploy:check:delayed_job_status"
after "deploy", "docker:version"

after "deploy:started", "figaro:setup"
after "deploy:symlink:release", "figaro:symlink"
