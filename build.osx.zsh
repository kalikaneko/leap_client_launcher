#!/bin/zsh
# Copyright (C) 2013 Kali Kaneko <kali@leap.se>
#
# This source  code is free  software; you can redistribute  it and/or
# modify it under the terms of  the GNU Public License as published by
# the Free  Software Foundation; either  version 3 of the  License, or
# (at your option) any later version.
#
# This source code is distributed in  the hope that it will be useful,
# but  WITHOUT ANY  WARRANTY;  without even  the  implied warranty  of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# Please refer to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, write to:
# Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

PROJECT="LEAP-CLIENT-LAUNCHER"
VERSION="0.0.1"
TOPSRC=`pwd`
LAUNCHER_DIR=${TOPSRC}/leap-launcher-osx
LAUNCHER_LIB=${LAUNCHER_DIR}/lib
BUILDDIR=${TOPSRC}/build-osx
CLIENT_REPO="git://leap.se/leap_client"
QUIET=0
DEBUG=0

PYTHON_SYSTEM="/Library/Python/2.6/site-packages"

autoload colors; colors
# standard output message routines
# it's always useful to wrap them, in case we change behaviour later
notice() { if [[ $QUIET == 0 ]]; then print "$fg_bold[green][*]$fg_no_bold[default] $1" >&2; fi }
error()  { if [[ $QUIET == 0 ]]; then print "$fg[red][!]$fg[default] $1" >&2; fi }
func()   { if [[ $DEBUG == 1 ]]; then print "$fg[blue][D]$fg[default] $1" >&2; fi }
act()    {
    if [[ $QUIET == 0 ]]; then
	if [ "$1" = "-n" ]; then
	    print -n "$fg_bold[white] . $fg_no_bold[default] $2" >&2;
	else
	    print "$fg_bold[white] . $fg_no_bold[default] $1" >&2;
	fi
    fi
}

{ test "$1" = "clean" } && {
	notice "Cleaning up build dir ${BUILDDIR}"
	rm -rf "${BUILDDIR}" 
	act "Done."
	return 0
}

do_build() {
	notice "Building ${PROJECT} ${VERSION}"
	mkdir $BUILDDIR
	cd $BUILDDIR
	cmake -DPYTHON_LIBRARIES=/usr/lib/libpython2.6.dylib ..
	make
	act "Done."

	notice "Copying to distribution dir"
	mkdir $LAUNCHER_DIR
	mkdir $LAUNCHER_DIR/apps
	mkdir -p $LAUNCHER_DIR/lib/site-packages
	cp src/launcher $LAUNCHER_DIR/leap-client
	act "Done."

	notice "Cloning leap_client and copy to dist dir"
	git clone $CLIENT_REPO
	cd leap_client
	git checkout develop
	cp -r src/leap $LAUNCHER_DIR/apps/
	cd $TOPSRC
	act "Done."
}

copy_deps() {
	notice "Copying python dependencies"
	cp -r $PYTHON_SYSTEM/PySide $LAUNCHER_LIB/site-packages/
	# XXX this is missing QtCore.framework/Versions/4/QtCore
	act "Done."
}

make_bundle() {
	# ...
}

make_dmg() {
	# ...
}

#do_build
copy_deps
#make_bundle
#make_dmg

notice "Distribution ready at $LAUNCHER_DIR !"
