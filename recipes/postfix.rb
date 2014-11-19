# copy new file if not exists or checksum mismatches
cookbook_file "/etc/postfix/postfix2redis.sh" do
  source "postfix2redis.sh"
  mode '0755'
  owner 'root'
  group 'root'
end

execute "postmap_access" do
  command "postmap /etc/postfix/access"
  action :nothing
end

execute "postfix_reload" do
  command "postfix reload"
  action :nothing
end


template "/etc/postfix/access" do
  source "postfix/access.erb"
  notifies :run, 'execute[postmap_access]', :delayed
end

template "/etc/postfix/master.cf" do
  source "postfix/master.cf.erb"
  #notifies :run, 'execute[postfix_reload]', :delayed # this will be ran later.
end

template "/etc/postfix/main.cf" do
  source "postfix/main.cf.erb"
  notifies :run, 'execute[postfix_reload]', :delayed
end


# # contains mail cli client
# yum_package "mailx" do
#   action :install
# end
