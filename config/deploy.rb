set :application, 'grader'

set :pty, true

set :repo_url, "git@github.com:ulyssecarion/grader.git"
set :scm, "git"
set :scm_passphrase, ""
set :ssh_options, { forward_agent: true }

set :linked_dirs, %w{public/system}

after "deploy", "deploy:restart"
after "deploy", "deploy:ping"
after "deploy", "delayed_job:restart"