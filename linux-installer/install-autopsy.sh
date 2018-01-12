#!/bin/bash
workingdir=`pwd`

echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
apt-key adv –keyserver hkp://keyserver.ubuntu.com:80 –recv-keys EEA14886
apt-get update
apt-get install build-essential debhelper fakeroot autotools-dev zlib1g-dev bzip2 libssl-dev libfuse-dev python-all-dev python3-all-dev
apt-get install software-properties-common wget xauth
apt-get install git git-svn build-essential libssl-dev libbz2-dev libz-dev ant automake autoconf libtool vim python-dev uuid-dev libfuse-dev libcppunit-dev libafflib-dev
apt-get install gstreamer1.0 solr-tomcat
apt-get install oracle-java8-installer software-properties-common wget xauth git git-svn
apt-get install build-essential libssl-dev libbz2-dev libz-dev ant automake autoconf libtool vim python-dev gstreamer1.0
apt-get install oracle-java8-set-default

export JAVA_HOME="/usr/lib/jvm/java-8-oracle/"
export JDK_HOME="/usr/lib/jvm/java-8-oracle/"
export JRE_HOME="/usr/lib/jvm/java-8-oracle/jre/"
export TSK_HOME=$workingdir/sleuthkit
 

# Grab libewf sources if necessary
if [ ! -d libewf ]
then
git clone https://github.com/libyal/libewf.git
fi
cd libewf
make clean
git pull

cd ..

# Grab sleuthkit sources if necessary
if [ ! -d sleuthkit ]
then
git clone https://github.com/sleuthkit/sleuthkit.git
fi
cd sleuthkit
make clean
git pull

cd ..

# Grab Autopsy sources if necessary
if [ ! -d autopsy ]
then
git clone https://github.com/sleuthkit/autopsy.git
fi
cd autopsy
git pull
cd ..

# Build libewf.
cd libewf
./synclibs.sh
./autogen.sh
./configure --enable-python --prefix=$workingdir/sleuthkit
make
make install

 

# Compile Sleuthkit
cd $workingdir/sleuthkit
./bootstrap
./configure --prefix=$workingdir/sleuthkit --with-libewf=$workingdir/libewf
make
make check
make install
cd bindings/java
ant dist-PostgreSQL
cd dist
ln -s Tsk_DataModel.jar Tsk_DataModel_PostgreSQL.jar

#build and run Autopsy

cd $workingdir/autopsy

ant clean
ant build
ant run
