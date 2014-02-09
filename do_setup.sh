# RVM ...
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm requirements
rvm install 2.0.0-p353

# Passenger
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https
echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger precise main' > /etc/apt/sources.list.d/passenger.list
chown root: /etc/apt/sources.list.d/passenger.list
chmod 600 /etc/apt/sources.list.d/passenger.list
apt-get update -y
apt-get install -y libapache2-mod-passenger

# This is uncharted territory ... now I'm going to try to install the app

# We need git
sudo apt-get install -y git-core

# Position ourselves ...
mkdir /webapps
cd /webapps

# Clone the repo -- TODO: automate this further?
git clone https://ulyssecarion@bitbucket.org/ulyssecarion/grader.git

# Something to automate:

# This file goes into /etc/apache2/sites-available/grader:

# <VirtualHost *:80>
#   ServerName www.graderapp.com
#   # !!! Be sure to point DocumentRoot to 'public'!
#   DocumentRoot /webapps/grader/public
#   # This is the Ruby to be used
#   PassengerRuby /usr/local/rvm/wrappers/ruby-2.0.0-p353/ruby
#   <Directory /webapps/grader/public>
#      # This relaxes Apache security settings.
#      AllowOverride all
#      # MultiViews must be turned off.
#      Options -MultiViews
#   </Directory>
# </VirtualHost>
# Then to activate it do:
# BUT DON'T DO THIS YET!
a2ensite grader     # activate grader
a2dissite default   # deactivate default

# Now to get the site to actually work ...
# Postgres needs this
sudo apt-get install -y postgresql postgresql-contrib libpq-dev postgresql-client-common
bundle install

# Now let's get the database ready to go!

# Set up in psql (idk how to automate this)
#
# Note that this is run as the postgres user.
sudo -u postgres psql
# Run this command. Username and password are from database.yml
# create user grader with password 'grader' createdb;
# \q (to get out)

# Finishing touches... prepare db, precompile assets
RAILS_ENV=production bundle exec rake db:create db:migrate assets:precompile

# It _should_ work. I had some issues with the hrefs used for CSS and JS, but a
# quick call to
#
# service apache2 restart
#
# Fixed that for me.
#
# Woop woop I did it!

# The server is having some issues with ownership of the ./public/system
# directory ... still working on figuring this out, but it looks like chown will
# be involved.
chown -R www-data /webapps

# Now let's get Docker going
curl -sL https://get.docker.io/ | sh

# This is where dumps of the database will go
mkdir /dumps

# Create the cron job that will take care of saving the database
whenever --update-crontab
