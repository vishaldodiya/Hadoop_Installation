#!/bin/bash

installed=$(apt-cache policy default-jdk | grep "Installed" | awk -F' ' '{print $2}')

#JDK Installation Check Up

if test $installed != "(none)"; then 
    echo "Jdk is already installed"
else
    echo "Installing new JDK"
        sudo apt-get install default-jdk
        echo "JDK Installed"
fi

#Installing SSH for running Hadoop in Psuedo-Distributed Mode



#echo $installed;