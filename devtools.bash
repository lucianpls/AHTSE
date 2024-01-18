
# Linux distro
distro() {
    case $(uname -a) in
    *\.amzn2\.*)
        echo "AL2";;
    *\.amzn20*)
        echo "Amazon";;
    *-Ubuntu*)
        echo "Ubuntu";;
    *CYGWIN*)
        echo "Cygwin";;
    *)
        echo "Unknown";;
    esac
}

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

devtools_Amazon() {
    # generic stuff
    sudo yum install -q -y python3 swig zstd httpd openssl mod_ssl
    sudo service httpd stop

    # Might need to self-certify

    if [ ! -e /etc/pki/tls/certs/localhost.crt ]
    then
        sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/pki/tls/private/localhost.key \
            -out /etc/pki/tls/certs/localhost.crt \
            -subj "/C=US/ST=Oregon/L=Los Angeles/O=AHTSE/OU=Org/CN=www.ahtse.com"
    fi

    # One of these might fail
    sudo yum install -q -y pip || sudo yum install -q -y pip3

    # development tools
    sudo yum install -q -y gcc gcc-c++ automake libtool

    # various depenencies
    sudo yum install -q -y tcl zlib-devel libcurl-devel\
        libpng-devel libjpeg-devel libwebp-devel python3-devel openssl-devel\
        httpd-devel libzstd-devel openjpeg2-devel
}

devtools_Unbutu() {
    export DEBIAN_FRONTEND=noninteractive
    yes | sudo DEBIAN_FRONTEND=noninteractive apt update
    yes | sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y python3 zstd apache2 openssl pip
    sudo service apache2 stop
    yes | sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
        build-essential tcl zlib1g-dev pkg-config libcurl4-openssl-dev\
        libpng-dev libjpeg-dev libwebp-dev python3-dev\
        libssl-dev apache2-dev libzstd-dev libopenjp2-7-dev
}

# main()
case $(distro) in
    AL2 | Amazon)
        devtools_Amazon
        ;;
    Ubuntu)
        devtools_Unbutu
        ;;
    *)
        echo "Unknown or unsupported distro $(distro)"
        ;;
esac

pip3 -q install boto3 pytest numpy

export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

[ -d $HOME/src/ ] || mkdir $HOME/src
pushd $HOME/src
# Prevent building cmake multiple times. Current version is 3.20
(command -v cmake > /dev/null && cmake --version | grep -q "version 3.2") || (
    refresh $GITHUB/Kitware/CMake v3.28.1
    pushd CMake
    NP=${NP:-$(nproc)}
    ./bootstrap --prefix=$PREFIX --parallel=$NP
    make -j $NP
    $SUDO make install
    popd
    rm -rf CMake
)

# To previous folder
popd
