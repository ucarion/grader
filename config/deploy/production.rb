set :stage, :production

server "162.243.207.97", user: "deploy", roles: [:web, :app, :db, :workers]
set :deploy_to, "/webapps/grader-cap"

set :rails_env, :production

set :branch, "master"
