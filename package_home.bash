# Build a tar with the files needed to produce a runtime instance
# Some system libraries might still be needed, for example libzstd
rm -f bin/{cmake,ctest,cpack}
tar -zcf ec2-home.tgz modules bin lib lib64 share/gdal share/proj
