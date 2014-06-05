#!/bin/bash
# vim: set ts=8 tw=0 noet :

#################################################################################
######
###### Get bootswatch.com stylesheet and font files
######
#################################################################################

git submodule foreach git pull || exit 1

_assets="vendor/assets"
mkdir -p $_assets/stylesheets $_assets/fonts || exit 1

_themes_css=""
_themes_raw=""
for _file in $(ls -1 bootswatch/*/bootstrap.css) ; do
	_file=${_file#bootswatch/}
	_theme=${_file%/bootstrap.css}
	_src="bootswatch/$_file"
	_dst="$_assets/stylesheets/$_theme.css"
	rm -f /tmp/css.tmp
	sed -e 's#\.\./fonts/#/assets/#g' $_src >/tmp/css.tmp || exit 1
	if cmp -s /tmp/css.tmp $_dst ; then
		rm -f /tmp/css.tmp
	else
		echo "copy: $_theme.css"
		mv /tmp/css.tmp $_dst || exit 1
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
	sed -e "/assets.precompile/s/=.*/= %w($_themes_css)/" \
			$_engine >/tmp/engine.tmp || exit 1
	if cmp -s /tmp/engine.tmp $_engine ; then
		rm -f /tmp/engine.tmp
	else
		echo "edit: $_engine"
		mv /tmp/engine.tmp $_engine || exit 1
	fi
fi

_version="lib/bootswatch_rails/version.rb"
if [ -s $_version ] ; then
	rm -f /tmp/version.tmp
	sed -e "/THEMES/s/=.*/= [$_themes_raw]/" \
			$_version >/tmp/version.tmp || exit 1
	if cmp -s /tmp/version.tmp $_version ; then
		rm -f /tmp/version.tmp
	else
		echo "edit: $_version"
		mv /tmp/version.tmp $_version || exit 1
	fi
fi

for _file in bootswatch/fonts/*.* ; do
	_file=${_file##*/}
	_src="bootswatch/fonts/$_file"
	_dst="$_assets/fonts/$_file"
	if ! cmp -s $_src $_dst ; then
		echo "copy: $_file"
		cp $_src $_dst || exit 1
	fi
done

exit 0

