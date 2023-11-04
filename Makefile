.PHONY: all help translate test clean update compass collect rebuild pre-venv-setup setup setup-gunicorn setup-nginx run-gunicorn-dev run-gunicorn-prod run-nginx

SETTINGS={{ project_name }}.settings
TEST_SETTINGS={{ project_name }}.test_settings
SHELL := /bin/bash

# target: all - Default target. Does nothing.
all:
	@echo "Hello $(LOGNAME), nothing to do by default"
	@echo "Try 'make help'"

# target: help - Display callable targets.
help:
	@egrep "^# target:" [Mm]akefile

# target: translate - calls the "makemessages" django command
translate:
	cd {{ project_name }} && django-admin.py makemessages --settings=$(SETTINGS) -i "site-static/*" -a --no-location

# target: test - calls the "test" django command
test:
	django-admin.py test --settings=$(TEST_SETTINGS)

# target: clean - remove all ".pyc" files
clean:
	django-admin.py clean_pyc --settings=$(SETTINGS)

# target: update - install (and update) pip requirements
update:
	pip install -U -r requirements.pip

# target: compass - compass compile all scss files
compass:
	cd {{ project_name }}/compass && compass compile

# target: collect - calls the "collectstatic" django command
collect:
	django-admin.py collectstatic --settings=$(SETTINGS) --noinput

# target: rebuild - clean, update, compass, collect, then rebuild all data
rebuild: clean update compass collect
	django-admin.py reset_db --settings=$(SETTINGS) --router=default --noinput
	django-admin.py syncdb --settings=$(SETTINGS) --noinput
 	#django-admin.py loaddata --settings=$(SETTINGS) <your fixtures here>

# setup: runs relevant commands for server setup
# create and start the venv manually yourself after this step.
pre-venv-setup:
	sudo apt install python3
	sudo apt install python-is-python3 
	sudo apt install python3-distutils
	sudo apt install python3-pip
	pip install virtualenv
	virtualenv -p python3 digitalocean

setup: 	
	pip install -r requirements.txt
	alias GET='http --follow --timeout 6'
	source DJANGO_SECRET_KEY
	python social_project/manage.py migrate

https:
	sudo snap install --classic certbot
	sudo ln -s /snap/bin/certbot /usr/bin/certbot
	sudo certbot --nginx --rsa-key-size 4096 --no-redirect

# makes directories for gunicorn
setup-gunicorn:
	sudo mkdir -pv /var/{log,run}/gunicorn/
	sudo chown -cR root:root /var/{log,run}/gunicorn/

setup-nginx:
	sudo apt-get install -y 'nginx=1.18.*'
	nginx -v
	sudo cp nginx-sites-available-setting /etc/nginx/sites-available/kevinmcd
	sudo cp nginx.conf-setting /etc/nginx/nginx.conf
	sudo ln -s /etc/nginx/sites-available/kevinmcd /etc/nginx/sites-enabled/kevinmcd
	sudo rm /etc/nginx/sites-enabled/default
	sudo nginx -t
	sudo mkdir -pv /var/www/kevinmcd.xyz/static/
	sudo chown -cR root:root /var/www/kevinmcd.xyz/
	python social_project/manage.py collectstatic

# runs gunicorn in the development environment
run-gunicorn-dev:
	gunicorn -c config/gunicorn/dev.py

# runs gunicorn in the production environment
run-gunicorn-prod:
	gunicorn -c config/gunicorn/prod.py

run-nginx:
	sudo systemctl start nginx
	sudo systemctl status nginx

## Makefile by magopian at https://gist.github.com/magopian/4077998