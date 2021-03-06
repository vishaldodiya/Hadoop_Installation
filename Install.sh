#!/bin/bash

uname=$(whoami)
hadoop_version="hadoop-2.7.3"
installed1=$(apt-cache policy default-jdk | grep "Installed" | awk -F' ' '{print $2}')

#JDK Installation Check Up

if test $installed1 != "(none)"; then 
    echo "=>Jdk is already installed"
else
    echo "=>Installing new JDK"
        sudo apt-get install default-jdk
        echo "=>JDK Installed"
fi

#Installing SSH for running Hadoop in Psuedo-Distributed Mode

installed2=$(apt-cache policy ssh | grep "Installed" | awk -F' ' '{print $2}')

if test $installed1 != "(none)"; then 
    echo "=>SSH is already installed"
else
    echo "=>Installing new SSH and rsync"
        sudo apt-get install ssh
        sudo apt-get install rsync
        echo "=>SSH & rsync are Installed"
fi

#Generating Public key to access SSH for Hadoop
echo "=>Generating public to access SSH for Hadoop"
echo "=>After complition of command if it shows key is already generated than press Y to overwrite"
echo "=>If it is not generated and ask for folder name where to install than press Enter"

ssh-keygen -t rsa -P ""

cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorised_keys

#Downoading Hadoop 
cd ~
wget -c http://mirror.symnds.com/software/Apache/hadoop/common/$hadoop_version/$hadoop_version.tar.gz
tar -zxvf hadoop-2.7.3.tar.gz


#Defining Environmental variable in .bashrc file
if grep -Fxq "#Environmental variable for Hadoop setup" .bashrc
then
	echo "already Written"		
else
    echo "#Environmental variable for Hadoop setup" >> .bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> .bashrc
    echo "export HADOOP_HOME=/home/$uname/$hadoop_version" >> .bashrc
    echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> .bashrc
    echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> .bashrc
fi

. ~/.bashrc

#Defining Environmental variable in Hadoop side

ubuntu_version=$(uname -i)


if grep -Fxq "#Environmental variable for Hadoop" $HADOOP_HOME/etc/hadoop/hadoop-env.sh
then
	echo "alresy written"
else
    echo "#Environmental variable for Hadoop" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
    echo "export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
    echo "export JAVA_HOME=/usr/lib/jvm/default-java" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

    

    if test $ubuntu_version = "x86_64";
    then
        echo "export HADOOP_INSTALL=/home/$uname/$hadoop_version" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

        echo 'export PATH=$PATH:$HADOOP_INSTALL/bin' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

        echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

        echo 'export HADOOP_MAPRED_HOME=$HADOOP_INSTALL' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

        echo 'export HADOOP_COMMON_HOME=$HADOOP_INSTALL' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

        echo 'export HADOOP_HDFS_HOME=$HADOOP_INSTALL' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

        echo 'export YARN_HOME=$HADOOP_INSTALL' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

        echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

        echo 'export HADOOP_OPTS=-Djava.library.path=$HADOOP_INSTALL/lib' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
    fi
fi

#Changing Localhost address

sudo sed -i -e 's/127.0.1.1/127.0.0.1/g' /etc/hosts

#Configuring Hadoop for Psuedo-Distributed Mode

if grep -Fxq "<!-- Hadoop edit -->" $HADOOP_HOME/etc/hadoop/hdfs-site.xml
then
	echo "alresy written"
else
    sudo sed -i -e 's/<configuration>/ /g' $HADOOP_HOME/etc/hadoop/hdfs-site.xml
    sudo sed -i -e 's/<\/configuration>/ /g' $HADOOP_HOME/etc/hadoop/hdfs-site.xml
    
    echo "<!-- Hadoop edit -->" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml    
    echo "<configuration>\n
            <property>\n
                <name>dfs.replication</name>\n
                <value>1</value>\n
            </property>\n
        </configuration>" >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
fi

if grep -Fxq "<!-- Hadoop edit -->" $HADOOP_HOME/etc/hadoop/core-site.xml
then
	echo "already written"
else
    sudo sed -i -e 's/<configuration>/ /g' $HADOOP_HOME/etc/hadoop/core-site.xml
    sudo sed -i -e 's/<\/configuration>/ /g' $HADOOP_HOME/etc/hadoop/core-site.xml
    
    echo "<!-- Hadoop edit -->" >> $HADOOP_HOME/etc/hadoop/core-site.xml
    echo "<configuration>\n
            <property>\n
                <name>fs.defaultFS</name>\n
                <value>hdfs://localhost:9000</value>\n
            </property>\n
            <property>\n
                <name>hadoop.tmp.dir</name>\n
                <value>/tmp</value>\n
                <description>A base for other temporary directories.</description>\n
            </property>\n
        </configuration>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
fi
#Creatimg Temp file for Hadoop

mkdir /home/$uname/$hadoop_version/temp

#This may not be needed for newer version


if test $ubuntu_version = "x86_64";
then
    if grep -Fxq "<!-- Hadoop edit -->" $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
    then
	    echo "alredy written"
    else
        sudo sed -i -e 's/<configuration>/ /g' $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
        sudo sed -i -e 's/<\/configuration>/ /g' $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
        
        echo "<!-- Hadoop edit -->" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
        echo "<configuration>\n
                <property>\n
                    <name>mapred.job.tracker</name>\n
                    <value>localhost:9001</value>\n
                </property>\n
            </configuration>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
    fi
    
else
    if grep -Fxq "<!-- Hadoop edit -->" $HADOOP_HOME/etc/hadoop/mapred-site.xml
    then
	    echo "alredy written"
    else
        sudo sed -i -e 's/<configuration>/ /g' $HADOOP_HOME/etc/hadoop/mapred-site.xml
        sudo sed -i -e 's/<\/configuration>/ /g' $HADOOP_HOME/etc/hadoop/mapred-site.xml
        echo "<!-- Hadoop edit -->" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
        echo "<configuration>\n
                <property>\n
                    <name>mapred.job.tracker</name>\n
                    <value>localhost:9001</value>\n
                </property>\n
            </configuration>" >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
    fi
    
fi

echo "Done Installation"


    
#echo $installed;
