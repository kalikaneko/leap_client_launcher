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
#
set -e

PROJECT="LEAP-CLIENT-LAUNCHER"
VERSION="0.0.1"
TOPSRC=`pwd`
OSXPKG=${TOPSRC}/pkg/osx
BUILDDIR=${TOPSRC}/build-osx
DISTDIR=$BUILDDIR/dist
LAUNCHER_DIR=${BUILDDIR}/leap-launcher-osx
LAUNCHER_LIB=${LAUNCHER_DIR}/lib
APP=$LAUNCHER_DIR/leap-client.app
APPDEF=$LAUNCHER_DIR/"LEAP Client.app"
STARTUPDIR=${BUILDDIR}/tuntaposx/StartupItems
EXTENSIDIR=${BUILDDIR}/tuntaposx/Extensions
TUNTAPINST=${BUILDDIR}/tuntap-installer
QTDEPLOY="macdeployqt"

REPOCLIENT="git://leap.se/leap_client"
CLIENTBRANCH="develop"

# XXX ----------------------------------------------------
# test builds
REPOCLIENT="https://github.com/kalikaneko/leap_client.git"
CLIENTBRANCH="osx-builds"
# --------------------------------------------------------

REPOTUNTAP="https://github.com/bbits/tuntaposx.git"
REPOCOCOASUDO="https://github.com/kalikaneko/cocoasudo.git"
QUIET=0
DEBUG=0

PYTHON_SYSTEM="/Library/Python/2.6/site-packages"
LIBS_SYSTEM="/usr/lib"
LEAP_SITEPKG="${WORKON_HOME}/leap-client/lib/python2.6/site-packages"

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
	rm -rf "${LAUNCHER_DIR}"
	act "Done."
	return 0
}

do_build() {
	notice "Building ${PROJECT} ${VERSION}"
	mkdir $BUILDDIR
	mkdir $BUILDDIR/dist
	cd $BUILDDIR
	# XXX cmake seems to be a little obstinated about
	# finding the python libs where it pleases... even
	# though this invocation, the "found" info in the cmake output seems to
	# be wrong.
	cmake -DPYTHON_LIBRARIES=/usr/lib/libpython2.6.dylib ..
	make
	act "Done."

	notice "Copying to distribution dir"
	mkdir $LAUNCHER_DIR
	mkdir $LAUNCHER_DIR/apps
	mkdir -p $LAUNCHER_DIR/lib/site-packages
	cp src/launcher $LAUNCHER_DIR
	act "Done."

	# XXX ------------------------------------------
	# split into client-clone --
	#notice "Cloning leap_client and copy to dist dir"

	git clone $REPOCLIENT
	cd leap_client
	git checkout $CLIENTBRANCH

	# XXX should get the tags here if the right flags are
	# passed
	
	#make resources
	#make ui
	#
	#generate an updated _version
	#python setup.py build
	#cp build/leap/_version $LAUNCHER_DIR/apps/leap/
	# XXX we should get the whole build tree from there

	# ----------------------------------------------
	#
	notice "Copying leap_client from develop to dist dir"
	#cp -r src/leap $LAUNCHER_DIR/apps/
	#
	# XXX hack mode on ---- You need to do a fresh build in the src -------------
	cp -r /Users/kaliy/leap/leap_client/src/leap $LAUNCHER_DIR/apps/ 
	cp /Users/kaliy/leap/leap_client/build/lib/leap/_version.py $LAUNCHER_DIR/apps/leap/
	# XXX hack mode off
	# ---------------------------------------------------------------------------
	cd $TOPSRC
	act "Done."
}

build_tuntap() {
	cd $TOPSRC
	test -d tuntaposx || git clone $REPOTUNTAP
	cd tuntaposx/tuntap
	notice "Building tuntaposx"
	make
	mkdir -p ${EXTENSIDIR}/tun.kext
	mkdir -p ${STARTUPDIR}
	cp -r tun.kext/* ${EXTENSIDIR}/tun.kext
	cp -r startup_item/tun ${STARTUPDIR}/
	cp $OSXPKG/tun.kext.leap/Info.plist ${EXTENSIDIR}/tun.kext/Contents/
	act "Done."
}

build_cocoasudo() {
	cd $TOPSRC
	notice "Copying cocoasudo (should compile it instead)"
	cp /Users/kaliy/leap/cocoasudo/build/Release/cocoasudo $LAUNCHER_DIR/
	chmod +x $LAUNCHER_DIR/cocoasudo

	# XXX compile here instead
	#git clone $REPOCOCOASUDO
	#cd cocoasudo
	#xcodebuild -project cocoasudo.xcodeproj
}

make_tuntap_installer() {
	platypus -P ${OSXPKG}/install-tuntaposx.platypus -y ${TUNTAPINST}
	cp -r ${EXTENSIDIR} ${TUNTAPINST}.app/Contents/
	cp -r ${STARTUPDIR} ${TUNTAPINST}.app/Contents/

	mv ${TUNTAPINST}.app/Contents/Resources/script ${TUNTAPINST}.app/Contents/Resources/install-kext
	cp ${OSXPKG}/install-tuntaposx.cocoasudo-wrapper ${TUNTAPINST}.app/Contents/Resources/script
	cp $LAUNCHER_DIR/cocoasudo ${TUNTAPINST}.app/Contents/Resources/

	# copy the little tiff for cocoasudo to show a custom leap icon
	cd $TOPSRC
	cp -r pkg/osx/leap-client.app/Contents/Resources/leap-client.tiff ${TUNTAPINST}.app/Contents/Resources/

	act "Done."
}

copy_deps() {
	notice "Copying dependencies"
	cd $TOPSRC
	# not copying pyside
	# cp -r $PYTHON_SYSTEM/PySide $LAUNCHER_LIB/site-packages/
	#
	# XXX doing something hacky here by now, till we get
	# the pyside libraries corrected to @loader_path
	# We currently just create an empty package structure
	# to where we copy PySide.QtCore and PySide.QtGui afterwards...
	
	mkdir $LAUNCHER_LIB/site-packages/PySide/
	touch $LAUNCHER_LIB/site-packages/PySide/__init__.py

	# copy all eggs from our leap-client py26-virtualenv.
	# This can be generated by this script if needed in the future.
	# site.init(path) will make those eggs accessible from site-packages
	cp -r $LEAP_SITEPKG/*.egg $LAUNCHER_LIB/site-packages/
	cp $LEAP_SITEPKG/*.pth $LAUNCHER_LIB/site-packages/

	# copy leap common, workaround namespace :(
	# should upload egg instead...
	cp -r $LEAP_SITEPKG/leap/common $LAUNCHER_LIB/../apps/leap/
	# XXX should check that the .pth is not there...

	# frecking g**gle is lame packaging its own shit
	cp -r $LEAP_SITEPKG/protobuf $LAUNCHER_LIB/site-packages/
	cp -r $LEAP_SITEPKG/google $LAUNCHER_LIB/site-packages/

	# moar special case, alas
	cp $LEAP_SITEPKG/_scrypt.so $LAUNCHER_LIB/site-packages/
	cp $LEAP_SITEPKG/scrypt.py $LAUNCHER_LIB/site-packages/
	cp $LEAP_SITEPKG/six.py $LAUNCHER_LIB/site-packages/

	act "Done."

}

make_bundle() {
	notice "Making osx bundle"
	cd $TOPSRC
	cp -r pkg/osx/leap-client.app $LAUNCHER_DIR
	mv $LAUNCHER_DIR/launcher $APP/Contents/MacOS
	mv $LAUNCHER_DIR/apps $APP/Contents/MacOS
	mv $LAUNCHER_DIR/lib $APP/Contents/MacOS

	#I have the binary there for now
	#mv $LAUNCHER_DIR/cocoasudo $APP/Contents/MacOS

	# copy pyside libraries
	cp "${LIBS_SYSTEM}/libpyside-python2.6.1.1.dylib" "${APP}"/Contents/MacOS
	cp "${LIBS_SYSTEM}/libshiboken-python2.6.1.1.dylib" "${APP}"/Contents/MacOS

	# NEEDS AUTOMATION -----------------------------------------
	# XXX copy PySide.QtCore, PySide.QtGui, QtCore and QtGui
	# with the proper @loader_path set.
	# Need to automate its creation (getting this from a pyinstaller run)
	
	cp ~/pyside-libs/QtCore "${APP}"/Contents/MacOS
	cp ~/pyside-libs/QtGui "${APP}"/Contents/MacOS
	cp ~/pyside-libs/PySide.QtCore.so "${APP}"/Contents/MacOS/lib/site-packages/PySide/QtCore.so
	cp ~/pyside-libs/PySide.QtGui.so  "${APP}"/Contents/MacOS/lib/site-packages/PySide/QtGui.so

	# XXX get absolute path for this
	# We need to copy this file, even if we're following the macqtdeploy approach.
	# There is a reference to this problem in pyinstaller Qt documentation.
	cp -r ~/qt_menu.nib "${APP}"/Contents/Resources
	# END NEEDS AUTOMATION -------------------------------------

	# copy tuntap installer and openvpn binary
	# XXX we need to build this here.
	cp /usr/bin/openvpn.leap "${APP}"/Contents/Resources/
	cp -r "${TUNTAPINST}.app" "${APP}/Contents/Resources"


	act "Done."

	# install the QtFrameworks in the bundle.
	# Note: this approach seems nice, if not because it conflicts
	# with the libraries being loaded from somewhere else (pyside I think),
	# so Qt crashing with a warning against loading two different set of binaries.
	#
	# cd $LAUNCHER_DIR
	#$QTDEPLOY leap-client.app -dmg
	#cd leap-client.app/Contents/Frameworks
	## some cleanup, more than we need, thanks
	#rm -rf QtDeclarative.framework
	#rm -rf QtXmlPatterns.framework
	#rm -rf QtSvg.framework
	#rm -rf QtNetwork.framework
	#rm -rf QtScript.framework
	#rm -rf QtSql.framework
}

make_dmg() {
	notice "Making DMG for distribution"
	mv $APP $APPDEF
	cp $OSXPKG/Makefile $DISTDIR
	cp $OSXPKG/leap-template.dmg.bz2 $DISTDIR
	cd $DISTDIR
	make

	# XXX old method, manual --------------------------
	#cd $BUILDDIR/leap_client
	#GITREV=`git rev-parse --short HEAD`
	#DMG=$BUILDDIR/dist/leap-client-${GITREV}.dmg
	#hdiutil create -format UDBZ -srcfolder $APPDEF $DMG
	
	act "Done."
}

do_build
build_tuntap
make_tuntap_installer
copy_deps
make_bundle
make_dmg

notice "Distribution .dmg ready at $DISTDIR! Happy release!"
