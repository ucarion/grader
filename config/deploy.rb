set :application, 'grader'

set :pty, true

set :repo_url, "git@github.com:ulyssecarion/grader.git"
set :scm, "git"
set :scm_passphrase, ""
set :ssh_options, { forward_agent: true }
