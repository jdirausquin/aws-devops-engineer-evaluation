#/bin/bash
wget https://packages.chef.io/files/stable/chefdk/2.5.3/ubuntu/16.04/chefdk_2.5.3-1_amd64.deb
sudo dpkg -i chefdk_2.5.3-1_amd64.deb
sudo mkdir /var/chef
cd /var/chef
sudo chef generate cookbook loadbalancer
sudo mkdir /var/chef/loadbalancer/files
sudo cp /tmp/loadbalancer/* /var/chef/loadbalancer/files/
sudo cat <<EOF >> /var/chef/loadbalancer/recipes/default.rb
package 'nginx' do
  action :install
end

service 'nginx' do
  action [ :enable, :start ]
end

cookbook_file "/var/www/html/index.html" do
  source "index.html"
  mode "0644"
end

cookbook_file "/etc/nginx/sites-available/default" do
  source "default.conf"
  mode "0644"
end

service 'nginx' do
  action [ :restart ]
end
EOF
echo "cookbook_path '/var/chef/'" > /var/chef/solo.rb
sudo chef-solo -c solo.rb -o 'recipe[loadbalancer]'
