leap_client_launcher
====================

Launcher application for the LEAP python client, its daemons (imap, smtp, soledad) and the updater

depends
-------
boost.python
boost.filesystem
boost.system

how to build
---------------
mkdir build
cd build
cmake ..
make

osx
-------

Download and compile boost.python:

 ./bootstrap.sh --prefix=$HOME/src/boost_install --with-libraries=python,filesystem,system
 ./bjam -j2 variant=release link=static macosx-version=10.4 macosx-version-min=10.4 threading=multi architecture=x86 toolset=darwin address-model=32_64 install

Add this to your .zshrc:

 export DYLD_LIBRARY_PATH="$HOME/src/boost_install/lib:${DYLD_LIBRARY_PATH}"

random notes
------------
kalis-macbook 福 /opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7 
2858 ◯ : cp -r config ~/leap/leap-launcher-osx/lib/lib/python2.7


