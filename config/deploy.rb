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
    on roles(:app) do
      tmp = File.join(current_path, 'tmp')
      restart_txt = File.join(tmp, 'restart.txt')

      execute "mkdir -p #{tmp}; touch #{restart_txt}"
    end
  end

  desc "Ping the server to force Passenger to reload"
  task :ping do
    on roles(:app) do |server|
      `curl #{server.hostname} > /dev/null 2>&1`
    end
  end
end

after "deploy", "deploy:restart"
after "deploy", "deploy:ping"
