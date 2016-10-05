#!/bin/bash

installed1=$(apt-cache policy default-jdk | grep "Installed" | awk -F' ' '{print $2}')

#JDK Installation Check Up

if test $installed1 != "(none)"; then 
    echo "Jdk is already installed"
else
    echo "Installing new JDK"
        sudo apt-get install default-jdk
        echo "JDK Installed"
fi

#Installing SSH for running Hadoop in Psuedo-Distributed Mode

installed2=$(apt-cache policy ssh | grep "Installed" | awk -F' ' '{print $2}')

if test $installed1 != "(none)"; then 
    echo "SSH is already installed"
else
    echo "Installing new SSH and rsync"
        sudo apt-get install ssh
        sudo apt-get install rsync
        echo "SSH & rsync are Installed"
fi

#echo $installed;