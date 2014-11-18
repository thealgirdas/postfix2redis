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


# contains mail cli client
yum_package "mailx" do
  action :install
end


# add the EPEL repo
yum_repository 'epel' do
  description 'Extra Packages for Enterprise Linux'
  mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
  gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
  action :create
end

yum_repository 'remi' do
  description 'remi packages'
  baseurl 'http://rpms.famillecollet.com/enterprise/6/remi/$basearch/'
  mirrorlist 'http://rpms.famillecollet.com/enterprise/6/remi/mirror'
  gpgkey 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
  action :create
end

# install redis server
yum_package "redis"

service 'redis' do
  action [:start, :enable]
end