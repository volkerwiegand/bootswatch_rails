# vim: set ts=8 tw=0 noet :
#
# Makefile for building the Gem
#

all: build
	git status

rel: build
	./generate.sh
	vim lib/bootswatch_rails/version.rb
	git commit -a
	sudo gem uninstall bootswatch_rails
	rake release

install: build
	vim lib/bootswatch_rails/version.rb
	git commit -a
	sudo rake install

build:
	test -d cleditor && git add cleditor || true
	git add lib
	git add vendor

