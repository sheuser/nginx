#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#
# Copyright 2012, Riot Games
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

Ohai.plugin(:Nginx) do
  provides "nginx"
  provides "nginx/version"
  provides "nginx/configure_arguments"
  provides "nginx/prefix"
  provides "nginx/conf_path"

  def parse_flags(flags)
    prefix = nil
    conf_path = nil

    flags.each do |flag|
      case flag
      when /^--prefix=(.+)$/
        prefix = $1
      when /^--conf-path=(.+)$/
        conf_path = $1
      end
    end

    [ prefix, conf_path ]
  end

  collect_data(:default) do

    nginx Mash.new unless nginx
    nginx[:version]             = nil unless nginx[:version]
    nginx[:configure_arguments] = Array.new unless nginx[:configure_arguments]
    nginx[:prefix]              = nil unless nginx[:prefix]
    nginx[:conf_path]           = nil unless nginx[:conf_path]

    status, stdout, stderr = run_command(:no_status_check => true, :command => "nginx -V")

    if status == 0
      stderr.split("\n").each do |line|
        case line
        when /^configure arguments:(.+)/
          # Split based on regex. Delete any elements if they do not begin with 2 leading hyphens '--'.
          nginx[:configure_arguments] = $1.split(/(--[a-z_0-9-]+=?('[^']+'|[^\s]+)?)/).delete_if { |e| ! e.start_with?('--') }

          prefix, conf_path = parse_flags(nginx[:configure_arguments])

          nginx[:prefix] = prefix
          nginx[:conf_path] = conf_path
        when /^nginx version: nginx\/(\d+\.\d+\.\d+)/
          nginx[:version] = $1
        end
      end
    end
  end
end