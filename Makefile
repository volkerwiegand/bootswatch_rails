# vim: set ts=8 tw=0 noet :
#
# Makefile for building the Gem
#

GEMNAME	:= bootswatch_rails

all: build

update:
	./generate.sh -u

build:
	./generate.sh
	git add lib
	git add vendor
	-git commit -a -m "Prepare for initial commit"
	rake build
	-sudo gem uninstall ${GEMNAME} --all --force
	sudo rake install

clean:
	-sudo gem uninstall ${GEMNAME} --all --force
	sudo rm -rf pkg

