##
# default.rb
# Installs php myadmin into an independent vhost on the development vm
# Cookbook Name:: php_myadmin
# Recipe:: default
# AUTHORS::   Seth Griffin <griffinseth@yahoo.com>
# Copyright:: Copyright 2015 Authors
# License::   GPLv3
#
# This file is part of PhpVagrantMulti.
# PhpVagrantMulti is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# PhpVagrantMulti is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with PhpVagrantMulti.  If not, see <http://www.gnu.org/licenses/>.
##

directory "/var/www/vhosts" do
    not_if { Dir.exists?("/var/www/vhosts") }
    owner "www-data"
    group "www-data"
    mode  "0755"
    action :create
end

directory node["phpMyAdmin"]["dir"] do
    owner "www-data"
    group "www-data"
    mode  "0755"
    action :create
end
                  
cookbook_file '/opt/phpMyAdmin-4.7.4-all-languages.zip' do
    source 'phpMyAdmin-4.7.4-all-languages.zip'
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    action :create
end

execute "unpack_phpmyadmin" do
    not_if { Dir.exists?("/opt/phpMyAdmin/phpMyAdmin-4.3.3-all-languages") }
    command "sudo unzip /opt/phpMyAdmin-4.7.4-all-languages.zip -d /opt/phpMyAdmin"
    action :run
end

directory "/var/www/vhosts/phpmyadmin.local" do
    owner "www-data"
    group "www-data"
    mode  "0755"
    action :create
end

execute "install_phpmyadmin" do
    command "sudo cp -r /opt/phpMyAdmin/phpMyAdmin-4.7.4-all-languages/* /var/www/vhosts/phpmyadmin.local/"
    action :run
end

template "phpmyadmin.local.conf" do
    path "#{node["apache"]["dir"]}/sites-available/phpmyadmin.local.conf"
    source "phpmyadmin.local.conf.erb"
    owner  "www-data"
    group  "www-data"
    mode   "0644"
end

execute "enable_phpmyadmin" do
    command "sudo a2ensite phpmyadmin.local"
    action :run
    notifies :restart, "service[apache2]", :immediately
end
