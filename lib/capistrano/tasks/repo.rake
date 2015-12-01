namespace :repo do

  desc "Install a new instance of the repository on a server"
  task :install do
    on roles(:app) do
      execute "cd #{fetch(:base_dir)} && git clone #{fetch(:repo_url)}"
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && HTTP_PROXY=#{fetch(:aic_proxy)} bundle install"
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && /usr/bin/env rake db:migrate"
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && /usr/bin/env rake rails:update:bin"
    end
  end

  desc "Install a new instance of the repository on a server"
  task :update do
    on roles(:app) do
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && git pull"
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && HTTP_PROXY=#{fetch(:aic_proxy)} bundle install"
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && /usr/bin/env rake db:migrate"
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && /usr/bin/env rake rails:update:bin"
    end
  end  

  desc "Configure a repo using yml files stored on server"
  task :config do
    on roles(:app) do
      execute "cp #{fetch(:aic_config_dir)}/*.yml #{fetch(:base_dir)}/aicdams-lakeshore/config/"
      execute "cp #{fetch(:aic_config_dir)}/fedora-cert.pem #{fetch(:base_dir)}/aicdams-lakeshore/config/"
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && /usr/bin/env rake fedora:load_fixtures"
    end
  end

  desc "Remove repo"
  task :delete do
    on roles(:app) do
      execute "rm -Rf #{fetch(:base_dir)}/aicdams-lakeshore"
    end
  end

  desc "Reinstall the database"
  task :db do
    on roles(:app) do
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && /usr/bin/env rake db:drop"
      execute "cd #{fetch(:base_dir)}/aicdams-lakeshore && /usr/bin/env rake db:create"      
    end
  end

  desc "Re-install repository"
  task reinstall: ["delete", "install", "config"]

end
