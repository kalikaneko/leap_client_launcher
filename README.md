leap_client_launcher
====================

Launcher application for the LEAP python client, its daemons (imap, smtp, soledad) and the updater

depends
-------
boost.python
boost.filesystem
boost.system

osx
-------

./build.osx.zsh clean && ./build.osx.zsh

Download and compile boost.python:

 ./bootstrap.sh --prefix=$HOME/src/boost_install --with-libraries=python,filesystem,system
 ./bjam -j2 variant=release link=static macosx-version=10.4 macosx-version-min=10.4 threading=multi architecture=x86 toolset=darwin address-model=32_64 install

Add this to your .zshrc:

 export DYLD_LIBRARY_PATH="$HOME/src/boost_install/lib:${DYLD_LIBRARY_PATH}"

Download and install Qt 4.7.4:

ftp://ftp.qt-project.org/qt/source/qt-mac-opensource-4.7.4.dmg

And PySide 1.1.0 for Python 2.6:

http://pyside-1.1.0-qt47-py26apple.pkg


