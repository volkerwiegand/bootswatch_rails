# vim: set ts=8 tw=0 noet :
#
# Makefile for building the Gem
#

all:
	./generate.sh
	test -d cleditor && git add cleditor || true
	git add lib
	git add vendor
	vim lib/bootswatch_rails/version.rb
	git commit -a
	rake release

