#!/bin/bash

# This builds and installs Unity. Also includes setup for Ubuntu Natty
# See http://askubuntu.com/questions/28470/how-do-i-build-unity-from-source/28472#28472

# Change this to where you want everything installed:
installprefix=/opt/unity

# flag to update nux and or unity
nux=1
unity=1

function set_env()
{
   export PKG_CONFIG_PATH=$installprefix/lib/pkgconfig:${PKG_CONFIG_PATH}
   export LD_LIBRARY_PATH=$installprefix/lib:${LD_LIBRARY_PATH}
   export LD_RUN_PATH=$installprefix/lib:${LD_RUN_PATH}
}

function unset_env()
{
   unset PKG_CONFIG_PATH
   unset LD_LIBRARY_PATH
   unset LD_RUN_PATH
}

function install_prerequisites()
{
    sudo apt-get install bzr cmake compiz-dev gnome-common libbamf-dev libboost-dev libboost-serialization-dev libcairo2-dev libdbusmenu-glib-dev libdee-dev libgconf2-dev libgdk-pixbuf2.0-dev libglew1.5-dev libglewmx1.5-dev libglib2.0-dev libindicator-dev libpango1.0-dev libpcre3-dev libsigc++-2.0-dev libunity-misc-dev libutouch-geis-dev
}

function clone()
{
   # Nux
   bzr branch lp:nux

   # Unity
   bzr branch lp:unity
}

function make_install_nux()
{
   if [ "$nux" == "1" ]
   then
      cd nux
      make -j4 && sudo make -j4 install
      cd ..
   fi
}

function make_install_unity()
{
   if [ "$unity" == "1" ]
   then
      set_env
      cd unity/build
      make -j4 && sudo make -j4 install
      if [ ! -d $installprefix/share/unity/places ]
      then
         sudo mkdir $installprefix/share/unity/places
      fi
      sudo cp /usr/share/unity/places/* $installprefix/share/unity/places/
      cd ../..
      unset_env
   fi

}

function configure()
{
   # have to build and install nux for unity to configure
   if [ "$nux" == "1" ]
   then
   cd nux
   ./autogen.sh --disable-documentation --prefix=$installprefix
   cd ..
   make_install_nux
   fi

   if [ "$unity" == "1" ]
   then
   set_env
   cd unity
   if [ ! -d build ]
   then
      mkdir build
   fi
   cd build
   cmake .. -DCMAKE_BUILD_TYPE=Debug -DCOMPIZ_PLUGIN_INSTALL_TYPE=package -DCMAKE_INSTALL_PREFIX=$installprefix
   cd ../..
   unset_env
   make_install_unity
   fi
}

function makemakeinstall()
{
   make_install_nux
   make_install_unity
}

function pull()
{
   if [ "$nux" == "1" ]
   then
   cd nux
   bzr pull
   cd ..
   fi

   if [ "$unity" == "1" ]
   then
   cd unity
   bzr pull
   cd ..  
   fi
}

function print_usage()
{
   echo "Usage:"
   echo "$0 env|make|build|pull|clone|run|prerequisites [nux|unity]"
   echo ""
   echo "configure     - Build the code (runs autogen, make, make install)"
   echo "make          - Rebuild the code (runs make, make install)"
   echo "pull          - bzr pull each of the repositories"
   echo "clone         - bzr clone each of the necessary repositories"
   echo "prerequisites - Install ubuntu pre-requisites"
   echo ""
   echo "To get started run: "
   echo "$0 prerequisites"
   echo "$0 clone"
   echo "$0 configure"
   echo "$0 make"
}


# skip argument parsing if we are being sourced in order
# to setup the wayland environment
if [ "/bin/bash" != "$0" ]
then
   set -e # exit script if anything fails
   #set -x # enable debugging

   # print usage if no arguments
   if [ $# -eq 0 ]
   then
      print_usage `basename $0`
      exit 1
   fi

   # check if only nux or unity should be updated
   if [ "$2" == "unity" ]
   then
      nux="0"
   elif [ "$2" == "nux" ]
   then
      unity="0"
   fi

   # handle the input argument
   if [ "$1" == "env" ]
   then
      echo "source this script via 'source $0' to setup your environment"
   elif [ "$1" == "pull" ]
   then
      pull
   elif [ "$1" == "clone" ]
   then
      clone
   elif [ "$1" == "configure" ]
   then
      configure
   elif [ "$1" == "make" ]
   then
      makemakeinstall
   elif [ "$1" == "prerequisites" ]
   then
      install_prerequisites
   else
      print_usage `basename $0`
   fi
fi

