set :application, 'grader'

set :pty, true

set :repo_url, "git@github.com:ulyssecarion/grader.git"
set :scm, "git"
set :scm_passphrase, ""
set :ssh_options, { forward_agent: true }

namespace :deploy do
  namespace :check do
    desc "Check that we can access everything"
    task :write_permissions do
      on roles(:all) do |host|
        if test("[ -w #{fetch(:deploy_to)} ]")
          info "#{fetch(:deploy_to)} is writable on #{host}"
        else
          error "#{fetch(:deploy_to)} is not writable on #{host}"
        end
      end
    end
  end

  desc "Restart Passenger app"
  task :restart do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end

after "deploy", "deploy:restart"
