# vim: set ts=8 tw=0 noet :
#
# Makefile for building the Gem
#

all:
	./generate.sh
	git add lib
	git add vendor
	git commit -a
	rake release

