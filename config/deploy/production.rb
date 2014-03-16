set :stage, :production

server "getcurriculum.com", user: "deploy", roles: [:web, :app, :db, :workers]
set :deploy_to, "/webapps/grader-cap"

set :rails_env, :production

set :branch, "master"
