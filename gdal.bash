
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

make_build() {
    make -j $NP 
    $SUDO make install
    make clean
}

# How many processors to use for compilation
NP=${NP:-$(nproc)}
pushd $HOME/src

# current master of sqlite3, needed by PROJ
# sqlite3 is already installed, so make sure this is our installation
(test -f $PREFIX/bin/sqlite3 && $PREFIX/bin/sqlite3 --version | grep -q "3.36") || (
    refresh $GITHUB/sqlite/sqlite release
    pushd sqlite
    ./configure --prefix=$PREFIX 
    make_build
    popd
)

# current master of PROJ, needed by gdal
(command -v proj && proj 2>&1 |grep -q "Rel. 8.0.1" ) || (
    refresh $GITHUB/OSGeo/PROJ 8.0.1
    pushd PROJ
    ./autogen.sh
    ./configure --prefix=$PREFIX --disable-tiff
    make_build
    popd
)

# My own brunsli
refresh $GITHUB/$ME/brunsli
pushd brunsli
git submodule update --init --recursive
mkdir out
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib -S . -B out
pushd out
make -s -j $NP
$SUDO make -s install
# install the third party library dependencies
$SUDO mv third_party/brotli/libbrotli*so* $PREFIX/lib
popd
rm -rf out
popd

# Finally, my gdal project
(command -v gdalinfo && gdalinfo --version |grep -q "GDAL 3.4." ) || (
    refresh $GITHUB/$ME/gdal
    pushd gdal/gdal
    # git switch brunsli
    # Use internal jpeg to get 12 bit capability
    # Use external jpeg to get 8 bit turbo
    ./configure --prefix=$PREFIX --with-python=python3 --with-proj=$PREFIX --with-sqlite3=$PREFIX --with-jpeg=internal --with-brunsli
    make_build
    popd
)

# From ~/src
popd

echo Remember to set PYTHONPATH and LD_LIBRARY_PATH