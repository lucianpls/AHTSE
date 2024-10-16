
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
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

# current master of sqlite3, needed by PROJ
# sqlite3 is already installed, so make sure this is our installation
(test -f $PREFIX/bin/sqlite3 && $PREFIX/bin/sqlite3 --version | grep -q "3.37") || (
    refresh $GITHUB/sqlite/sqlite version-3.37.2
    pushd sqlite
    ./configure --prefix=$PREFIX --enable-rtree --disable-tcl
    make_build
    popd
)

# current master of PROJ, needed by gdal
(command -v proj && proj 2>&1 |grep -q "Rel. 9.4.0" ) || (
    refresh $GITHUB/OSGeo/PROJ 9.4.0
    pushd PROJ
    mkdir out
    cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib -DENABLE_TIFF=OFF -S . -B out
    pushd out
    make_build
    popd
    rm -rf out
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
popd
rm -rf out
popd

# My own QB3, build only the library since libicd is not available yet
refresh $GITHUB/$ME/QB3
BDIR=QB3/out
mkdir $BDIR
pushd $BDIR
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib -S ..
make -s -j $NP
$SUDO make -s install
popd
rm -rf $BDIR

# Libgeos, optional, enables geometry calculations in ogr
refresh $GITHUB/libgeos/geos
pushd geos
mkdir build
pushd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib -S ..
make_build
popd
rm -rf build
popd

# My gdal, cmake build
(command -v gdalinfo && gdalinfo --version |grep -q "GDAL 3.10." ) || (
    refresh $GITHUB/$ME/gdal
    pushd gdal
    mkdir build
    pushd build
    cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
        -DCMAKE_BUILD_TYPE=Release -S ..
    make_build
    popd
    rm -rf build
    popd
)

# mrf specific tools, ie 
refresh $GITHUB/nasa-gibs/mrf
pushd mrf/mrf_apps
$SUDO cp `find $HOME/src/gdal -name marfa.h` $PREFIX/include
cat >Makefile.lcl <<END_LABEL
PREFIX=$PREFIX
GDAL_ROOT=$PREFIX/src/gdal/gdal
END_LABEL
make install
cp *.py $PREFIX/bin
popd

# From ~/src
popd

# Set up environment for using gdal
export PYTHONPATH=$(echo $PREFIX/lib64/python3.*/site-packages)
export LD_LIBRARY_PATH=$PREFIX/lib
grep -q PYTHONPATH $HOME/.bashrc
if [ ! -z $? ]
then
cat >>$HOME/.bashrc <<END_LABEL
export PYTHONPATH=$PYTHONPATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
END_LABEL
fi
