#!/bin/fish

set -l script_dir (dirname (status --current-filename))
set -l pkg_dir "$script_dir/build/dist/plasmoid"
set -l pkg_file "$script_dir/build/dist/panon.plasmoid"

if not test -d $pkg_dir
	echo "Package directory $pkg_dir not found. Run ./build.sh first."
	exit 1
end

if not test -f $pkg_file
	echo "Package archive $pkg_file not found. Expected ./makepackage.sh to have run."
	exit 1
end

if not type -q kpackagetool6
	echo "kpackagetool6 not found in PATH; cannot auto-install the plasmoid."
	exit 1
end

# Remove any previously installed copy to force Plasma to load the freshly built bits.
kpackagetool6 -t Plasma/Applet --remove panon > /dev/null 2>&1
kpackagetool6 -t Plasma/Applet --install $pkg_file

plasmawindowed panon
