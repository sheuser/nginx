#
# Cookbook Name:: nginx
# Attributes:: naxsi
#
# Author:: Artiom Lunev (<artiom.lunev@gmail.com>)
#
# Copyright 2012, Artiom Lunev
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

default['nginx']['naxsi']['version']  = "0.52"
default['nginx']['naxsi']['url']      = "https://github.com/nbs-system/naxsi/archive/#{node['nginx']['naxsi']['version']}.tar.gz"
default['nginx']['naxsi']['checksum'] = "381cd5937c265ddcbabf55516028f4b0d1f67222f576c987afb2f676248f8be2"