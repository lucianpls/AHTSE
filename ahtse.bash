
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

ahtse_make() {
    module=$1
    refresh $GITHUB/$ME/$module
    pushd $module/src
    make -j $NP MAKEOPT=$MAKEOPT
    $SUDO make install MAKEOPT=$MAKEOPT
    make clean MAKEOPT=$MAKEOPT
    popd
}

# How many processors to use for compilation
NP=${NP:-$(nproc)}
pushd $HOME/src

# libicd is not part of AHTSE, build with cmake
refresh $GITHUB/$ME/libicd
mkdir libicd/build
pushd libicd/build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib ..
make -s -j $NP
$SUDO make -s install
popd
rm -rf libicd/build

export MAKEOPT=$HOME/src/Make.opt

cat <<LABEL >$MAKEOPT
APXS = apxs
CP = cp
PREFIX = $PREFIX
SUDO = $SUDO

includedir = \$(shell \$(APXS) -q includedir 2>/dev/null)
EXTRA_INCLUDES = \$(shell \$(APXS) -q EXTRA_INCLUDES 2>/dev/null)
LIBTOOL = \$(shell \$(APXS) -q LIBTOOL 2>/dev/null)
LIBEXECDIR = \$(shell \$(APXS) -q libexecdir 2>/dev/null)
EXP_INCLUDEDIR = \$(PREFIX)/include
DEST = \$(PREFIX)/modules
LABEL

ahtse_make mod_brunsli
ahtse_make mod_receive
ahtse_make libahtse

#These depend on libahtse
ahtse_make mod_sfim
ahtse_make mod_mrf
ahtse_make mod_twms
ahtse_make mod_fillin
ahtse_make mod_retile
ahtse_make mod_pngmod
ahtse_make mod_convert
ahtse_make mod_ecache

#Deploy, this may prevent rebuilding gdal
# This will fail on Unbutu since apache is installed as apache2
sudo cp $PREFIX/lib/libicd.so $PREFIX/lib/libbrunsli*-c.so /lib64
sudo cp $PREFIX/modules/*.so /etc/httpd/modules

# Create it here, copy it to the system folder
cat >ahtse.conf <<END_LABEL
# AHTSE modules

# These are independent

# Brunsli codec filter
LoadModule brunsli_module modules/mod_brunsli.so
# Receive filter
LoadModule receive_module modules/mod_receive.so
# Send a file based on a URL regexp
LoadModule sfim_module modules/mod_sfim.so

# First load libahtse, otherwise the other modules fail loading
LoadFile modules/libahtse.so

# Source from an MRF file, either local or in object store
LoadModule mrf_module modules/mod_mrf.so

# Source from an Esri Bundled cache, either local or in object store
# When operating in proxy mode, build local cache in Esri Bundles
LoadModule ecache_module modules/mod_ecache.so

# Convert WMS requests to AHTSE M/L/R/C
LoadModule twms_module modules/mod_twms.so

# Scale and reproject tiles
LoadModule retile_module modules/mod_retile.so

# Fill in high resolution tiles
LoadModule fillin_module modules/mod_fillin.so

# Modify pngs on the fly
LoadModule pngmod_module modules/mod_pngmod.so

# Tile data conversions
LoadModule convert_module modules/mod_convert.so
END_LABEL

sudo cp ahtse.conf /etc/httpd/conf.modules.d/

# Test that everything loads
httpd -t
