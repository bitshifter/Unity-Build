#!/bin/bash

# This builds and installs Unity. Also includes setup for Ubuntu Natty

# Change this to where you want everything installed:
installprefix=/opt/unity

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
   sudo apt-get install bzr libglib2.0-dev libgdk-pixbuf2.0-dev libcairo2-dev libpng12-dev libglew1.5-dev  libglewmx1.5-dev libxxf86vm-dev libgl1-mesa-dev libsigc++-2.0-dev libpango1.0-dev doxygen cmake build-essential debhelper pkg-config valac intltool libgee-dev libunique-dev libclutter-1.0-dev libclutter-gtk-0.10-dev libclutk-dev libbamf-dev gsettings-desktop-schemas-dev libgconf2-dev  libglib2.0-dev libdbusmenu-glib-dev libgnome-desktop-dev libgtk2.0-dev libpango1.0-dev libgnomeui-dev libdee-dev libindicator-dev  libunity-misc-dev libutouch-grail-dev libxcb-icccm1-dev compizconfig-settings-manager compiz-dev libboost-dev libboost-serialization-dev libmetacity-dev python-dev cython gnome-common libpcre3-dev
}

function clone()
{
   # Nux
   bzr branch lp:nux

   # Unity
   bzr branch lp:unity
}

function configure()
{
   # have to build and install nux for unity to configure
   cd nux
   ./autogen.sh --disable-documentation --prefix=$installprefix
   make
   sudo make install
   cd ..

   set_env

   cd unity
   if [ ! -d build ]
   then
      mkdir build
   fi
   cd build
   cmake .. -DCMAKE_BUILD_TYPE=Debug -DCOMPIZ_PLUGIN_INSTALL_TYPE=package -DCMAKE_INSTALL_PREFIX=$installprefix
   make
   sudo make install
   cd ../..

   unset_env
}

function makemakeinstall()
{
   cd nux
   make
   sudo make install
   cd ..

   set_env

   cd unity/build
   make
   make install
   cd ../..

   unset_env
}

function pull()
{
   cd nux
   bzr pull
   cd ..

   cd unity
   bzr pull
   cd ..  
}

function print_usage()
{
   echo "Usage:"
   echo "$0 [env|make|build|pull|clone|run|prerequisites]"
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

   # print usage if we don't have 1 argument
   if [ $# -ne 1 ]
   then
      print_usage `basename $0`
      exit 1
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

