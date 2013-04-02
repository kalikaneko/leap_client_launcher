#!/bin/bash

# Tun/Tap for OSX Driver Installer Script.
#
# Copyright (C) 2013 LEAP Encryption Access Project
#
# This file is part of the LEAP Client, as
# available from http://leap.se/. This file is free software;
# you can redistribute it and/or modify it under the terms of the GNU
# General Public License (GPL) as published by the Free Software
# Foundation, in version 2 as it comes in the "COPYING" file of the
# LEAP Client distribution. LEAP Client is distributed in the
# hope that it will be useful, but WITHOUT ANY WARRANTY of any kind.
#

set -e

SYSLIB=/System/Library
SYSEXT=${SYSLIB}/Extensions
SYSSTARTUP=${SYSLIB}/StartupItems
TUNEXT=${SYSEXT}/tun.kext

echo "Installing tun/tap drivers..." > /dev/stderr
test -d ${TUNEXT} && kextunload ${TUNEXT}

cp -r ../Extensions/tun.kext ${SYSEXT}/
chown -R root:wheel ${SYSEXT}/tun.kext
chmod -R 755 ${SYSEXT}/tun.kext
cp -r ../StartupItems/tun  ${SYSSTARTUP}
chown -R root:wheel ${SYSSTARTUP}/tun

echo "Loading tun/tap kernel extension..." > /dev/stderr
kextload ${TUNEXT}
echo "Installation Finished!" > /dev/stderr
echo "Done." > /dev/stderr
