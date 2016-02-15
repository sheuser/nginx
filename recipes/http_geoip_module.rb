#
# Cookbook Name:: nginx
# Recipe:: http_geoip_module
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

country_dat         = "#{node['nginx']['geoip']['path']}/GeoIP.dat"
city_dat            = "#{node['nginx']['geoip']['path']}/GeoLiteCity.dat"
geolib_filename     = ::File.basename(node['nginx']['geoip']['lib_url'])
geolib_filepath     = "#{Chef::Config['file_cache_path']}/#{geolib_filename}"
geolib_extract_path = Chef::Config['file_cache_path']

package 'libtool'
directory node['nginx']['geoip']['path'] do
  recursive true
end

unless ::File.exist?("/usr/local/lib/libGeoIP.so.#{node['nginx']['geoip']['lib_version']}")
  remote_file geolib_filepath do
    source node['nginx']['geoip']['lib_url']
    not_if { File.exist?(geolib_filepath) }
  end
  bash 'extract_geolib' do
    cwd geolib_extract_path
    code <<-EOH
      tar xzf #{geolib_filepath} --no-same-owner -C #{geolib_extract_path}
      cd GeoIP-#{node['nginx']['geoip']['lib_version']}
      autoreconf -i
      which libtoolize && libtoolize -f
      ./configure
      make && make install
    EOH
    environment('echo' => 'echo') if node['platform_family'] == 'rhel' && node['platform_version'].to_f < 6
    creates "/usr/local/lib/libGeoIP.so.#{node['nginx']['geoip']['lib_version']}"
    subscribes :run, "remote_file[#{geolib_filepath}]"
  end
end

unless ::File.exist?(country_dat)
  remote_file "#{node['nginx']['geoip']['path']}/#{::File.basename(node['nginx']['geoip']['country_dat_url'])}" do
    source node['nginx']['geoip']['country_dat_url']
    not_if { File.exist?(country_dat) }
  end
  bash 'gunzip_geo_lite_country_dat' do
    cwd node['nginx']['geoip']['path']
    code <<-EOH
      gunzip -c "#{node['nginx']['geoip']['path']}/#{::File.basename(node['nginx']['geoip']['country_dat_url'])}" > #{country_dat}
    EOH
    creates country_dat
  end
end

unless ::File.exist?(city_dat)
  if node['nginx']['geoip']['enable_city']
    remote_file "#{node['nginx']['geoip']['path']}/#{::File.basename(node['nginx']['geoip']['city_dat_url'])}" do
      not_if do
        File.exist?(city_dat) &&
          File.mtime(city_dat) > Time.now - 86_400
      end
      source node['nginx']['geoip']['city_dat_url']
    end
    bash 'gunzip_geo_lite_city_dat' do
      cwd node['nginx']['geoip']['path']
      code <<-EOH
        gunzip -c "#{node['nginx']['geoip']['path']}/#{::File.basename(node['nginx']['geoip']['city_dat_url'])}" > #{city_dat}
      EOH
      creates city_dat
    end
  end
end

directory node['nginx']['geoip']['path'] do
  owner 'root'
  group node['root_group']
  mode 00755
  recursive true
end

template "#{node['nginx']['dir']}/conf.d/http_geoip.conf" do
  source 'modules/http_geoip.conf.erb'
  owner 'root'
  group node['root_group']
  mode 00644
  variables(
    :country_dat => country_dat,
    :city_dat => city_dat,
    :enable_city_dat => node['nginx']['geoip']['enable_city']
  )
end

cron 'run geoip update' do
  minute '0'
  hour '1'
  day '*'
  month '*'
  weekday '2'
  command <<-EOH
    [ `date +\%d` -le 7 ] && wget "#{node['nginx']['geoip']['country_dat_url']}" -O "#{node['nginx']['geoip']['path']}/GeoIP.dat.gz" && mv #{node['nginx']['geoip']['path']}/GeoIP.dat #{node['nginx']['geoip']['path']}/GeoIP.dat.bak && gzip -d #{node['nginx']['geoip']['path']}/GeoIP.dat.gz > /dev/null 2>&1
  EOH
end

node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ['--with-http_geoip_module', "--with-ld-opt='-Wl,-R,/usr/local/lib -L /usr/local/lib'"]
