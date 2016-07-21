#
# Cookbook Name:: nginx
# Recipe:: default
#

include_recipe "nginx::#{node['nginx']['install_method']}"

#service 'nginx' do
#  supports :status => true, :restart => true, :reload => true
#  action   :start
#end

node['nginx']['default']['modules'].each do |ngx_module|
  include_recipe "nginx::#{ngx_module}"
end

logrotate_app 'nginx' do
  path "#{node['nginx']['log_dir']}/*.log"
  frequency 'daily'
  rotate 2
  options %w(missingok compress delaycompress notifempty sharedscripts)
  postrotate "[-f #{node['nginx']['pid']}] && kill -USR1 `cat #{node['nginx']['pid']}`"
  create "640 #{node['nginx']['user']} adm"
end
