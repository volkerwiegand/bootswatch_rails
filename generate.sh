#!/bin/bash
# vim: set ts=8 tw=0 noet :

#################################################################################
######
###### Get bootswatch.com stylesheet and font files
######
#################################################################################

# Exit on error 
set -e                  

if [ "$1" != "local" ] ; then
	git submodule foreach git pull
fi

_assets="vendor/assets"
for _dir in fonts images javascripts stylesheets ; do
	mkdir -p $_assets/$_dir
	touch $_assets/$_dir/.gitkeep
done


#################################################################################
###### Setup Bootswatch
#################################################################################

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


#################################################################################
###### Setup DataTables
#################################################################################

_src="DataTables/media/js/jquery.dataTables.js"
_dst="$_assets/javascripts/jquery.dataTables.js"
if ! cmp -s $_src $_dst ; then
	echo "copy: jquery.dataTables.js"
	cp $_src $_dst
fi

_src="DataTables/media/css/jquery.dataTables.css"
_dst="$_assets/stylesheets/jquery.dataTables.css"
rm -f /tmp/css.tmp
sed -e 's#\.\./images/#/assets/#g' $_src >/tmp/css.tmp
if cmp -s /tmp/css.tmp $_dst ; then
	rm -f /tmp/css.tmp
else
	echo "copy: jquery.dataTables.css"
	mv /tmp/css.tmp $_dst
fi
# _themes_css="jquery.dataTables.css $_themes_css"


#################################################################################
###### Update asset pipeline
#################################################################################

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


#################################################################################
###### Update theme list
#################################################################################

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


#################################################################################
###### Copy font files
#################################################################################

for _file in bootswatch/fonts/*.* ; do
	_file=${_file##*/}
	_src="bootswatch/fonts/$_file"
	_dst="$_assets/fonts/$_file"
	if ! cmp -s $_src $_dst ; then
		echo "copy: $_file"
		cp $_src $_dst
	fi
done


#################################################################################
###### Copy image files
#################################################################################

for _file in DataTables/media/images/*.png ; do
	_file=${_file##*/}
	_src="DataTables/media/images/$_file"
	_dst="$_assets/images/$_file"
	if ! cmp -s $_src $_dst ; then
		echo "copy: $_file"
		cp $_src $_dst
	fi
done


#################################################################################
###### Include CLEditor if found
#################################################################################

if [ -s cleditor/jquery.cleditor.js ] ; then
	_src="cleditor/jquery.cleditor.js"
	_dst="vendor/assets/javascripts/jquery.cleditor.js"
	sed -e 's/\r//g' $_src >/tmp/cleditor.tmp
	if cmp -s /tmp/cleditor.tmp $_dst ; then
		rm -f /tmp/cleditor.tmp
	else
		echo "edit: $_dst"
		mv /tmp/cleditor.tmp $_dst
	fi

	_src="cleditor/jquery.cleditor.css"
	_dst="vendor/assets/stylesheets/jquery.cleditor.css.scss"
	sed -e 's/\r//g' -e "s/url.*toolbar/asset_url('toolbar/" \
			 -e "s/url.*buttons/asset_url('buttons/" $_src >/tmp/cleditor.tmp
	if cmp -s /tmp/cleditor.tmp $_dst ; then
		rm -f /tmp/cleditor.tmp
	else
		echo "edit: $_dst"
		mv /tmp/cleditor.tmp $_dst
	fi

	_dir="lib/generators/bootswatch_rails/install/templates/app/assets/images"
	for _file in toolbar.gif buttons.gif ; do
		_src="cleditor/images/$_file"
		if ! cmp -s $_src $_dir/$_file ; then
			echo "copy: $_src"
			cp $_src $_dir/$_file
		fi
	done
fi

exit 0

