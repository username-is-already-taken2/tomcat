#
# Cookbook:: tomcat
# Recipe:: server
#
# Copyright:: 2017, The Authors, All Rights Reserved.

package 'java-1.7.0-openjdk-devel' do
  action :install
end

user 'tomcat' do
  action :create
end

group 'tomcat' do
  members 'tomcat'
  action :create
end

remote_file '/tmp/apache-tomcat-8.0.46.tar.gz' do
  source 'http://apache.mirrors.nublue.co.uk/tomcat/tomcat-8/v8.0.46/bin/apache-tomcat-8.0.46.tar.gz'
  action :create
end

remote_file '/tmp/sample.war' do
  source 'https://raw.githubusercontent.com/johnfitzpatrick/certification-workshops/master/Tomcat/sample.war'
  action :create
end

directory '/opt/tomcat' do
  action :create
end

bash 'untar the archive' do
  code <<-EOH
  tar -zxvf /tmp/apache-tomcat-8.0.46.tar.gz -C /opt/tomcat --strip-components=1
  EOH
  action :run
  not_if { ::File.exist?('/opt/tomcat/LICENSE') }
end

directory '/opt/tomcat/conf' do
  group 'tomcat'
  mode '0070'
  recursive true
  action :create
  notifies :run, 'execute[chgrp for all files in conf]', :immediately
  notifies :run, 'execute[chmod files in conf]', :immediately
  notifies :run, 'execute[chown tomcat folders]', :immediately
end

execute 'chgrp for all files in conf' do
  command 'chgrp -R tomcat /opt/tomcat/conf'
  action :nothing
end

execute 'chmod files in conf' do
  command 'chmod g+r /opt/tomcat/conf/*'
  action :nothing
end

execute 'chown tomcat folders' do
  command 'chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/'
  action :nothing
end

template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  notifies :run, 'execute[daemon-reload]', :immediately
  notifies :enable, 'service[tomcat]', :immediately
  notifies :start, 'service[tomcat]', :immediately
end

execute 'daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

service 'tomcat' do
  action :nothing
end
