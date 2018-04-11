#/bin/bash
wget https://packages.chef.io/files/stable/chefdk/2.5.3/ubuntu/16.04/chefdk_2.5.3-1_amd64.deb
sudo dpkg -i chefdk_2.5.3-1_amd64.deb
sudo mkdir /var/chef
cd /var/chef
sudo chef generate cookbook backend
sudo mkdir /var/chef/backend/files
sudo cp /tmp/backend/* /var/chef/backend/files/
sudo cat <<EOF >> /var/chef/backend/recipes/default.rb
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
EOF
echo "cookbook_path '/var/chef/'" > /var/chef/solo.rb
sudo chef-solo -c solo.rb -o 'recipe[backend]'
