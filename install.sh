#!/bin/sh
# CellPHY installation script 
# Created by: Alexey Kozlov, Joao M Alves, Alexandros Stamatakis & David Posada - July 2020

os_detect()
{
 if [ `uname -a | grep -c Darwin` -eq 1 ]; then
   return "osx"
 elif [ `uname -a | grep -c Ubuntu` -eq 1 ]; then
   return "ubuntu"
 elif [ `uname -a | grep -c CentOS` -eq 1 ]; then
   return "redhat"
 else
   return "unknown"
 fi
}

install_package(os, name)
{
  if [ "$os" == "ubuntu" ]; then
    sudo apt -y install $name
  elif [ "$os" == "redhat" ]; then
    sudo yum install $name
  elif [ "$os" == "osx" ]; then
    echo "Automatic install on macOS is not supported, sorry!"
    echo "Please install bcftools and R manually, and re-run this script."
    exit 1
  else
    echo "Unknown OS: ", $os
  fi
}

os=os_detect()

echo "Operating system detected: ", $os

# install bcftools
if [ `which bcftools | wc -l` -eq 0 ];
   install_package($os, "bcftools")
fi

# install R
if [ `which Rscript | wc -l` -eq 0 ];
   install_package($os, "r-base")
fi

# install R packages
root=`dirname $0`
echo "Installing required R packages..."
$root/scripts/install.R

echo "Done!"