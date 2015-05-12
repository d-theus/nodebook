namespace :mrlu do

  desc 'Update MRLU repo'
  task :pull do
    on roles(:app) do
      execute 'cd /var/www/nodebook/web/more-responsive-less-ui && git pull'
    end
  end
end
