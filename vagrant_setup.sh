sudo apt-get update

sudo apt-get install -y curl
sudo apt-get install -y build-essential
sudo apt-get install -y libpq-dev
sudo apt-get install -y git

git config --global color.ui true

curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh

rvm install 2.0.0-p353
gem install --no-ri --no-rdoc bundler

cd /vagrant

bundle
