cmake_minimum_required(VERSION 2.8.3)

PROJECT(leap-client-launcher)
SET (VERSION 0.0.1-dev)

SET(Boost_USE_STATIC_LIBS ON)

IF(APPLE)
 SET(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} "/Users/kaliy/src/boost_install/include")
 SET(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} "/Users/kaliy/src/boost_install/lib")
 #SET(PYTHON_INCLUDE_PATH ${PYTHON_INCLUDE_PATH} "/opt/local/Library/Frameworks/Python.framework/Versions/2.7/include")
 #SET(PYTHON_LIBRARY_PATH ${PYTHON_LIBRARY_PATH} "/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib")
 SET(CMAKE_OSX_ARCHITECTURES x86_64;i386)
 SET(CMAKE_OSX_SYSROOT /Developer/SDKs/MacOSX10.7.sdk)
ENDIF(APPLE)

FIND_PACKAGE(PythonInterp)
FIND_PACKAGE(PythonLibs)
FIND_PACKAGE(Boost COMPONENTS python filesystem system)

INCLUDE_DIRECTORIES(${Boost_INCLUDE_DIRS} ${PYTHON_INCLUDE_DIRS})

ADD_SUBDIRECTORY(src)
