# # # # #
# geoip #
# # # # #
default['nginx']['geoip']['path'] = '/var/geoip'
default['nginx']['geoip']['enable_city'] = true
default['nginx']['geoip']['country_dat_url'] = 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz'
default['nginx']['geoip']['country_dat_checksum'] = '6802f06eb4225dfb1f22e186f5565fb062efe7e1e29810a0715a55c968da5bc4'
default['nginx']['geoip']['city_dat_url'] = 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz'
default['nginx']['geoip']['city_dat_checksum'] = '0e40ff174d2281dbd76fea11654d27d4d944a35cca44e2a235642668119b1aeb'
default['nginx']['geoip']['lib_version'] = '1.6.2'
default['nginx']['geoip']['lib_url'] = "http://geolite.maxmind.com/download/geoip/api/c/GeoIP-#{node['nginx']['geoip']['lib_version']}.tar.gz"
default['nginx']['geoip']['lib_checksum'] = '8ef059ee3680b39db967248331ec41188f4b45f86a4a77e39247ff41b61efd7c'
