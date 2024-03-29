# Project Makefile
# ================
#
# - https://github.com/aclark4life/project-makefile
#
#
# License
# ------------------------------------------------------------------------------ 
#
# Copyright 2020 Jeffrey Alexander Clark
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# Overview of concepts
# ------------------------------------------------------------------------------ 
#
# Goal
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
# 
# "By default, the goal is the first target in the makefile (not counting targets
# that start with a period). Therefore, makefiles are usually written so that the
# first target is for compiling the entire program or programs they describe. If
# the first rule in the makefile has several targets, only the first target in the
# rule becomes the default goal, not the whole list. You can manage the selection
# of the default goal from within your makefile using the .DEFAULT_GOAL variable
# (see Other Special Variables)."
# 
# - https://www.gnu.org/software/make/manual/html_node/Goals.html
#
# Default goal
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
#  
# "Sets the default goal to be used if no targets were specified on the command 
# line (see Arguments to Specify the Goals). The .DEFAULT_GOAL variable allows
# you to discover the current default goal, restart the default goal selection
# algorithm by clearing its value, or to explicitly set the default goal."
#
# - https://www.gnu.org/software/make/manual/html_node/Special-Variables.html#Special-Variables
#
# Variables
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
# "A variable is a name defined in a makefile to represent a string of text, called
# the variable's value. These values are substituted by explicit request into targets,
# prerequisites, recipes, and other parts of the makefile."
#
# - https://www.gnu.org/software/make/manual/html_node/Using-Variables.html
#
# Flavors
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
# "The first flavor of variable is a recursively expanded variable. Variables of
# this sort are defined by lines using ‘=’ (see Setting Variables) or by the
# define directive (see Defining Multi-Line Variables). The value you specify
# is installed verbatim; if it contains references to other variables, these
# references are expanded whenever this variable is substituted (in the course
# of expanding some other string). When this happens, it is called recursive expansion.
#
# To avoid all the problems and inconveniences of recursively expanded variables,
# there is another flavor: simply expanded variables.
#
# Simply expanded variables are defined by lines using ‘:=’ or ‘::=’ (see Setting
# Variables). Both forms are equivalent in GNU make; however only the ‘::=’ form
# is described by the POSIX standard (support for ‘::=’ was added to the POSIX
# standard in 2012, so older versions of make won’t accept this form either)."
#
# - https://www.gnu.org/software/make/manual/html_node/Flavors.html#Flavors
#
# Rules
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
# "A rule appears in the makefile and says when and how to remake certain files,
# called the rule's targets (most often only one per rule). It lists the other
# files that are the prerequisites of the target, and the recipe to use to
# create or update the target."
#
# - https://www.gnu.org/software/make/manual/html_node/Rules.html
#
# Overrides
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
# "Sometimes it is useful to have a makefile that is mostly just like another makefile.
# You can often use the ‘include’ directive to include one in the other, and add more
# targets or variable definitions. However, it is invalid for two makefiles to give
# different recipes for the same target. But there is another way."
#
# - https://www.gnu.org/software/make/manual/html_node/Overriding-Makefiles.html
#
# Includes
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
# "The include directive tells make to suspend reading the current makefile and
# read one or more other makefiles before continuing.
# 
# - https://www.gnu.org/software/make/manual/html_node/Include.html
#
#
# Additional concepts
# ------------------------------------------------------------------------------ 
#
# Alias
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# A new target definition that only exists to create a shorter target 
# name for another target that already exists.
#
# Multi-target Alias
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
# Like an Alias, but with multiple targets.
#
#
# Variables
# ------------------------------------------------------------------------------  
#
.DEFAULT_GOAL := usage

MESSAGE := Update

PROJECT := project
APP := app

# https://stackoverflow.com/a/589260/185820
TMPDIR := $(shell mktemp -d)
RANDIR := $(shell openssl rand -base64 12 | sed 's/\///g')
UNAME := $(shell uname)

# http://unix.stackexchange.com/a/37316
BRANCHES = `git branch -a | grep remote | grep -v HEAD | grep -v master`


# Rules
# ------------------------------------------------------------------------------  
#
# Django
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
django-start:
	-mkdir -p $(PROJECT)/$(APP)/templates
	-touch $(PROJECT)/$(APP)/templates/base.html
	-django-admin startproject $(PROJECT) .
	-django-admin startapp $(APP) $(PROJECT)/$(APP)
django-init: 
	@$(MAKE) pip-install-django
	@$(MAKE) pg-init
	@$(MAKE) django-start
	@$(MAKE) django-config
	git add $(PROJECT)
	git add manage.py
	@$(MAKE) commit-push
django-migrate-default:
	python manage.py migrate
django-migrations-default:
	python manage.py makemigrations $(APP)
	git add $(PROJECT)/$(APP)/migrations/*.py
django-serve-default:
	python manage.py runserver 0.0.0.0:8000
django-test-default:
	python manage.py test
django-config:
	echo "STATIC_ROOT = 'static'" >> $(PROJECT)/settings.py
	echo "ALLOWED_HOSTS = ['*']" >> $(PROJECT)/settings.py
	echo "AUTH_PASSWORD_VALIDATORS = [{'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator', }, { 'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator', },]" >> $(PROJECT)/settings.py
	echo "import dj_database_url; DATABASES = { 'default': dj_database_url.config(default=os.environ.get( 'DATABASE_URL', 'postgres://%s:%s@%s:%s/%s' % (os.environ.get('DB_USER', ''), os.environ.get('DB_PASS', ''), os.environ.get('DB_HOST', 'localhost'), os.environ.get('DB_PORT', '5432'), os.environ.get('DB_NAME', 'project_app'))))}" >> $(PROJECT)/settings.py
django-shell:
	python manage.py shell
django-static:
	python manage.py collectstatic --noinput
django-su:
	python manage.py shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('admin', '', 'admin')"
django-loaddata-default:
	python manage.py loaddata
django-yapf:
	-yapf -i *.py
	-yapf -i $(PROJECT)/*.py
	-yapf -i $(PROJECT)/$(APP)/*.py
django-wc:
	-wc -l *.py
	-wc -l $(PROJECT)/*.py
	-wc -l $(PROJECT)/$(APP)/*.py
django-graph:
	python manage.py graph_models $(APP) -o graph_models_$(PROJECT)_$(APP).png 
graph: django-graph
migrate: django-migrate  # Alias
migrations: django-migrations  # Alias
static: django-static  # Alias
su: django-su  # Alias
test: django-test  # Alias
loaddata: django-loaddata  # Alias
#
# Git
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
git-ignore:
	echo ".Python\nbin/\ninclude/\nlib/\n.vagrant/\n" >> .gitignore
	git add .gitignore
	$(MAKE) commit-push
git-init:
	git init
	hub create $(RANDDIR)
	hub browse
git-branches:
	-for i in $(BRANCHES) ; do \
        git checkout -t $$i ; done
git-prune:
	git remote update origin --prune
git-commit:
	git commit -a -m $(MESSAGE)
git-commit-edit:
	git commit -a
git-push:
	git push
git-push-up:
	git push --set-upstream origin master
commit: git-commit  # Alias
ce: commit-edit  # Alias
cp: commit-push  # Alias
push: git-push  # Alias
p: push  # Alias
commit-push: git-commit git-push  # Multi-target Alias
commit-push-up: git-commit git-push-up  # Multi-target Alias
commit-edit: git-commit-edit git-push  # Multi-target Alias
#
# Misc
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
rand:
	@openssl rand -base64 12 | sed 's/\///g'
r: rand  # Alias
#
readme:
	echo "Creating README.rst"
	@echo $(PROJECT) > README.rst
	@echo "================================================================================\n" >> README.rst
	@echo $(APP) >> README.rst
	@echo -------------------------------------------------------------------------------- >> README.rst
	echo "Done."
	git add README.rst
	@$(MAKE) commit-push
#
review:
ifeq ($(UNAME), Darwin)
	@open -a $(EDITOR) `find $(PROJECT) -name \*.py | grep -v __init__.py | grep -v migrations`\
		`find $(PROJECT) -name \*.html` `find $(PROJECT) -name \*.js`
else
	@echo "Unsupported"
endif
#
list-targets-default:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F:\
        '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}'\
        | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs | tr ' ' '\n' | awk\
        '{print "make "$$0}' | less  # http://stackoverflow.com/a/26339924
help: list-targets  # Alias
h: list-targets  # Alias
pdf-default:
	rst2pdf README.rst > README.pdf
	git add README.pdf
	$(MAKE) commit-push
#
usage:
	@echo "Project Makefile"
	@echo "Usage:\n"
	@echo "\tmake <target>\n"
	@echo "Help:\n"
	@echo "\tmake help"
#
make:
	git add base.mk
	git add Makefile
	@$(MAKE) commit-push
#
deploy-default:
	eb deploy
d: deploy  # Alias
#
# MySQL
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
my-init-default:
	-mysqladmin -u root drop $(PROJECT)_$(APP)
	-mysqladmin -u root create $(PROJECT)_$(APP)
#
# Pip
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
PIP := pip --use-feature=2020-resolver
pip-freeze-default:
	$(PIP) freeze | sort > $(TMPDIR)/requirements.txt
	mv -f $(TMPDIR)/requirements.txt .
pip-install-default:
	$(PIP) install -r requirements.txt
pip-install-test:
	$(PIP) install -r requirements-test.txt
pip-install-django:
	@echo "Django\ndj-database-url\npsycopg2-binary\n" > requirements.txt
	@$(MAKE) pip-install
	@$(MAKE) freeze
	-git add requirements.txt
	-@$(MAKE) commit-push-up
pip-install-sphinx:
	echo "Sphinx\n" > requirements.txt
	$(MAKE) pip-install
pip-upgrade-default:
	cat requirements.txt | awk -F \= '{print $$1}' > $(TMPDIR)/requirements.txt
	mv -f $(TMPDIR)/requirements.txt .
	$(PIP) install -U -r requirements.txt
	$(MAKE) pip-freeze
pip-upgrade-pip:
	$(PIP) install -U pip
pip-init:
	touch requirements.txt
	git add requirements.txt
	$(MAKE) commit-push
freeze: pip-freeze  # Alias
install-default: pip-install  # Alias
install-test-default: pip-install-test  # Alias
pip-up: pip-upgrade  # Alias
pip-up-pip: pip-upgrade-pip  # Alias
req: pip-init-requirements  # Alias
up-pip: pip-upgrade-pip  # Alias
up: pip-upgrade  # Alias
#
# PostgreSQL
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
pg-init-default:
	-dropdb $(PROJECT)_$(APP)
	-createdb $(PROJECT)_$(APP)
#
# Python
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
python-serve-default:
	@echo "\n\tServing HTTP on http://0.0.0.0:8000\n"
	python -m http.server
python-virtualenv-2-6-default:
	virtualenv --python=python2.6 .
python-virtualenv-2-7-default:
	virtualenv --python=python2.7 .
python-virtualenv-3-8-default:
	python3.8 -m venv .
python-virtualenv-3-9-default:
	python3.9 -m venv .
#
# Sphinx
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
sphinx-build-default:
	sphinx-build -b html -d _build/doctrees . _build/html
sphinx-init:
	$(MAKE) pip-install-sphinx
	sphinx-quickstart -q -p $(PROJECT) -a $(USER) -v 0.0.1 $(RANDIR)
	mv $(RANDIR)/* .
	rmdir $(RANDIR)
sphinx-serve-default:
	cd _build/html;python -m http.server
#
# Vagrant
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
#
vagrant-init:
	vagrant init ubuntu/trusty64
	git add Vagrantfile
	$(MAKE) git-push-up
	$(MAKE) vagrant-up
vagrant-up:
	vagrant up --provider virtualbox
vagrant: vagrant-init  # Alias
vm: vagrant-init  # Alias
vm-up: vagrant-up  # Alias
#
# Overrides
# ------------------------------------------------------------------------------  
#
# https://stackoverflow.com/a/49804748
%: %-default
	@ true
