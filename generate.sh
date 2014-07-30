#!/bin/bash
# vim: set ts=8 tw=0 noet :

#################################################################################
######
###### Get bootswatch.com stylesheet and font files
######
#################################################################################

# Exit on error 
set -e                  

git submodule foreach git pull

_assets="vendor/assets"
mkdir -p $_assets/stylesheets $_assets/fonts

_themes_css=""
_themes_raw=""
for _file in $(ls -1 bootswatch/*/bootstrap.css) ; do
	_file=${_file#bootswatch/}
	_theme=${_file%/bootstrap.css}
	_src="bootswatch/$_file"
	_dst="$_assets/stylesheets/$_theme.css"
	rm -f /tmp/css.tmp
	sed -e 's#\.\./fonts/#/assets/#g' $_src >/tmp/css.tmp
	if cmp -s /tmp/css.tmp $_dst ; then
		rm -f /tmp/css.tmp
	else
		echo "copy: $_theme.css"
		mv /tmp/css.tmp $_dst
	fi
	if [ -z "$_themes_css" ] ; then
		_themes_css="$_theme.css"
	else
		_themes_css="$_themes_css $_theme.css"
	fi
	if [ -z "$_themes_raw" ] ; then
		_themes_raw=":$_theme"
	else
		_themes_raw="$_themes_raw, :$_theme"
	fi
done

_engine="lib/bootswatch_rails/engine.rb"
if [ -s $_engine ] ; then
	rm -f /tmp/engine.tmp
	sed -e "/assets.precompile/s/=.*/= %w($_themes_css)/" $_engine >/tmp/engine.tmp
	if cmp -s /tmp/engine.tmp $_engine ; then
		rm -f /tmp/engine.tmp
	else
		echo "edit: $_engine"
		mv /tmp/engine.tmp $_engine
	fi
fi

_version="lib/bootswatch_rails/version.rb"
if [ -s $_version ] ; then
	rm -f /tmp/version.tmp
	sed -e "/THEMES/s/=.*/= [$_themes_raw]/" $_version >/tmp/version.tmp
	if cmp -s /tmp/version.tmp $_version ; then
		rm -f /tmp/version.tmp
	else
		echo "edit: $_version"
		mv /tmp/version.tmp $_version
	fi
fi

for _file in bootswatch/fonts/*.* ; do
	_file=${_file##*/}
	_src="bootswatch/fonts/$_file"
	_dst="$_assets/fonts/$_file"
	if ! cmp -s $_src $_dst ; then
		echo "copy: $_file"
		cp $_src $_dst
	fi
done

exit 0

