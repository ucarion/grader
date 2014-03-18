set :application, 'grader'

set :pty, true

set :repo_url, "git@github.com:ulyssecarion/grader.git"
set :scm, "git"
set :scm_passphrase, ""
set :ssh_options, { forward_agent: true }

set :linked_dirs, %w{public/system}

after "deploy", "deploy:restart"
after "deploy", "deploy:ping"
after "deploy", "delayed_job:stop"
after "deploy", "delayed_job:start"
after "deploy", "deploy:check:write_permissions"
after "deploy", "deploy:check:docker_group"
after "deploy", "deploy:check:delayed_job_status"
# before "deploy:assets:precompile", "figaro:setup"
# before "deploy:assets:precompile", "figaro:symlink"
