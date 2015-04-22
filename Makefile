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
	gem uninstall bootswatch_rails --all
	rake release

install: build
	git commit -a
	gem uninstall bootswatch_rails --all
	rake install
	rm -rf pkg

build:
	test -d datatables && git add datatables || true
	test -d cleditor && git add cleditor || true
	git add lib
	git add vendor

