# 
# For Amazon Linux 2, x64 or ARM
# Also Amazon Linux 2023, Ubuntu
#

# GIT ID
export ME=lucianpls
export THIS_PROJECT=AHTSE
export GITHUB=https://github.com

sudo yum install -q -y git || sudo apt-get install -q -y git

refresh() {
    project=$(basename $1)
    if [[ ! -d $project ]]
    then
        git clone -q $1
    else
        (cd $project; git pull -q)
    fi
    if [[ ! -z "$2" ]]
    then
        (cd $project; git checkout -q $2)
    fi

}

# Set PREFIX to /usr/local for system install, otherwise $HOME is used
export PREFIX=${PREFIX:-$HOME}
[ -d $HOME/src/ ] || mkdir $HOME/src

# $SUDO to be used for install commands
if [[ $PREFIX =~ ^/usr ]]
then
SUDO=sudo
else
SUDO=
fi

$SUDO mkdir $PREFIX/{bin,lib,include,modules}

# How many processors to use for compilation
export NP=$(nproc)
export PATH=$HOME/bin:$PATH
export LD_LIBRARY_PATH=$HOME/lib

pushd $HOME/src

refresh $GITHUB/$ME/$THIS_PROJECT
# Execute the updated scripts
. $HOME/src/$THIS_PROJECT/devtools.bash
. $HOME/src/$THIS_PROJECT/gdal.bash
. $HOME/src/$THIS_PROJECT/ahtse.bash

# To previous folder
popd
