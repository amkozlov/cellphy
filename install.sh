#!/bin/sh
# CellPhy installation script 
# Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - July 2021

os_detect()
{
 if [ `uname -a | grep -c Darwin` -eq 1 ]; then
   os=osx
 elif [ `uname -a | grep -c Ubuntu` -eq 1 ]; then
   os=ubuntu
 elif [ `uname -a | grep -c CentOS` -eq 1 ]; then
   os=redhat
 else
   os=unknown
 fi
}

install_package()
{
  local name=$1
  if [ "$os" == "ubuntu" ]; then
    sudo apt -y install $name
  elif [ "$os" == "redhat" ]; then
    sudo yum install $name
  elif [ "$os" == "osx" ]; then
    echo "Automatic install on macOS is not supported, sorry!"
    echo "Please install bcftools and R manually, and re-run this script."
    exit 1
  else
    echo "Unknown OS: $os"
  fi
}

os_detect

echo "Operating system detected: $os"

# install bcftools
if [ `which bcftools | wc -l` -eq 0 ]; then
   install_package bcftools
fi

# install R
if [ `which Rscript | wc -l` -eq 0 ]; then
   install_package r-base
fi

# install R packages
root=`dirname $0`
echo "Installing required R packages..."
$root/script/install.R

echo "Done!"
