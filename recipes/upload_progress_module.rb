#
# Cookbook Name:: nginx
# Recipe:: upload_progress_module
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#
# Copyright 2012-2013, Riot Games
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

upm_src_filename = ::File.basename(node['nginx']['upload_progress']['url'])
upm_src_filepath = "#{Chef::Config['file_cache_path']}/#{upm_src_filename}.tar.gz"
upm_extract_path = Chef::Config['file_cache_path']

unless ::File.exist?("#{upm_extract_path}/#{upm_src_filename}/config")
  remote_file upm_src_filepath do
    source node['nginx']['upload_progress']['url']
  end
  bash 'extract_upload_progress_module' do
    cwd  ::File.dirname(upm_extract_path)
    code <<-EOH
      tar xzf #{upm_src_filepath} --no-same-owner -C #{upm_extract_path}
      mv #{upm_extract_path}/nginx-upload-progress-module-#{node['nginx']['upload_progress']['version']}/*/* #{upm_extract_path}/nginx-upload-progress-module-#{node['nginx']['upload_progress']['version']}/
    EOH
  end
end

template "#{node['nginx']['dir']}/conf.d/upload_progress.conf" do
  source 'modules/upload_progress.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :reload, 'service[nginx]', :delayed
end

node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=#{upm_extract_path}/nginx-upload-progress-module-#{node['nginx']['upload_progress']['version']}"]
