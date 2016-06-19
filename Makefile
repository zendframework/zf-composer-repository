# Makefile for packages.zendframework.com composer repository
#
# Parameters you should pass in:
#
# - PHP=<path to php> (if you want to specify a specific PHP binary)
#
# You can override any given parameter by passing it in the command line or
# defining an equivalent ENV variable via export.

PHP?=php
COMPOSER_HOME?=/var/local/composer
export COMPOSER_HOME

COMPOSER=$(CURDIR)/bin/composer
PUBLIC=$(CURDIR)/../htdocs
GIT_REPOS?=/mnt/efs/packages.zendframework.com/repos

.PHONY: clean composer-vendor composer

all: composer

composer-vendor:
	@echo "Ensuring satis dependencies are installed..."
ifeq ($(wildcard vendor/autoload.php),)
	@echo "Installing composer dependencies for satis"
	-$(PHP) $(COMPOSER) install
ifeq ($$?,0)
	@echo "Composer installation failed"
	exit 1
endif
endif
	@echo "[DONE] Ensuring satis dependencies are installed."

git-repos:
	@echo "Syncing git repositories..."
	@for repo in $(GIT_REPOS)/zendframework/* $(GIT_REPOS)/zfcampus/*;do \
		echo "Updating $${repo}"; \
		(cd $${repo} ; git fetch -q origin && git fetch -q --tags origin && git checkout -q master && git rebase -q origin/master) ; \
		(cd $${repo} ; if [ "$$(git branch --list develop)" != "" ];then git checkout -q develop && git rebase -q origin/develop ; else if [ "$$(git branch --list -a origin/develop)" != "" ];then git checkout -q -b develop origin/develop ; fi ; fi) ; \
	done
	@echo "[DONE] Syncing git repositories."

composer: composer-vendor git-repos
	@echo "Running satis to create composer repository..."
	-$(PHP) -d "memory_limit=-1" $(CURDIR)/bin/satis build --skip-errors $(CURDIR)/satis.json $(PUBLIC)
	-sed -re 's#$(GIT_REPOS)([^"]+)#https://github.com\1.git#g' --in-place $$(ls -t $(PUBLIC)/include | head -n 1)
	@echo "[DONE] Running satis to create composer repository."
