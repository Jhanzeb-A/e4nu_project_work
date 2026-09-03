#!/bin/tcsh

setenv GENIE_BASE /work/clas12/$USER/genie-local
setenv GENIE_VERSION R-3_06_02
setenv NCPU 8
mkdir -p ${GENIE_BASE}/src
mkdir -p ${GENIE_BASE}/install
mkdir -p ${GENIE_BASE}/build
mkdir -p ${GENIE_BASE}/logs
mkdir -p ${GENIE_BASE}/production
setenv CC `which gcc`
setenv CXX `which g++`
setenv FC `which gfortran`
setenv F77 `which gfortran`
setenv F90 `which gfortran`
cd ${GENIE_BASE}/src
curl -L -o gsl-2.8.tar.gz https://ftp.gnu.org/gnu/gsl/gsl-2.8.tar.gz
tar xzf gsl-2.8.tar.gz
cd gsl-2.8
./configure --prefix=${GENIE_BASE}/install/gsl-2.8
make -j ${NCPU} |& tee ${GENIE_BASE}/logs/gsl-build.log
make install | & tee ${GENIE_BASE}/logs/gsl-install.log
cd ${GENIE_BASE}/src
curl -L -o libxml2-2.12.10.tar.xz https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.10.tar.xz
tar xJf libxml2-2.12.10.tar.xz
cd libxml2-2.12.10
./configure --prefix=${GENIE_BASE}/install/libxml2-2.12.10 --without-python
make -j ${NCPU} | & tee ${GENIE_BASE}/logs/libxml2-build.log
make install | & tee ${GENIE_BASE}/logs/libxml2-install.log
cd ${GENIE_BASE}/src
curl -fL -o log4cpp-1.1.4.tar.gz 'https://sourceforge.net/projects/log4cpp/files/log4cpp-1.1.x%20%28new%29/log4cpp-1.1/log4cpp-1.1.4.tar.gz/download'
tar xzf log4cpp-1.1.4.tar.gz
cd log4cpp
./configure  --prefix=${GENIE_BASE}/install/log4cpp-1.1.4   --disable-static
make -j ${NCPU} |& tee ${GENIE_BASE}/logs/log4cpp-build.log
make install |& tee ${GENIE_BASE}/logs/log4cpp-install.log
cd ${GENIE_BASE}/src
git clone --branch ${GENIE_VERSION}  --depth 1   https://github.com/GENIE-MC/Generator.git  Generator-${GENIE_VERSION}
mkdir -p ${GENIE_BASE}/src/pythia6
cd ${GENIE_BASE}/src/pythia6
bash ${GENIE_BASE}/src/Generator-${GENIE_VERSION}/src/scripts/build/ext/build_pythia6.sh   6.4.28 gfortran |& tee ${GENIE_BASE}/logs/pythia6-build.log
setenv PYTHIA6 ${GENIE_BASE}/src/pythia6/v6_428
cd "${GENIE_BASE}/src"
curl -L -o root_v6.30.08.source.tar.gz   "https://root.cern/download/root_v6.30.08.source.tar.gz"
tar xzf root_v6.30.08.source.tar.gz
mv root-6.30.08 root-6.30.08-source
mkdir -p "${GENIE_BASE}/build/root-6.30.08"
mkdir -p "${GENIE_BASE}/logs"
cd "${GENIE_BASE}/build/root-6.30.08"
setenv GSL_PREFIX ${GENIE_BASE}/install/gsl-2.8
cmake ${GENIE_BASE}/src/root-6.30.08-source -DCMAKE_INSTALL_PREFIX=${GENIE_BASE}/install/root-6.30.08 -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}  -DCMAKE_Fortran_COMPILER=${FC} -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=${GSL_PREFIX} -Dmathmore=ON -Dpythia6=ON -DPYTHIA6_LIBRARY=${PYTHIA6}/lib/libPythia6.so -Dx11=OFF -Dopengl=OFF -Ddavix=OFF -Dbuiltin_davix=OFF -Dmysql=OFF -Dpgsql=OFF -Doracle=OFF -Dsqlite=OFF -Dtmva=OFF -Droofit=OFF -Dssl=ON -Dxml=ON -Dbuiltin_xrootd=OFF -Dtesting=OFF |& tee ${GENIE_BASE}/logs/root-6.30.08-configure.log
cmake --build . --parallel ${NCPU} | & tee ${GENIE_BASE}/logs/root-6.30.08-build.log
cmake --install .   |& tee ${GENIE_BASE}/logs/root-6.30.08-install.log
source ${GENIE_BASE}/install/root-6.30.08/bin/thisroot.csh
cd ${ROOTSYS}/bin
ln -s root.exe root
rehash
nano ${GENIE_BASE}/setup_genie.csh
source ${GENIE_BASE}/setup_genie.csh
cd ${GENIE_BASE}/src
curl -L "https://lhapdf.hepforge.org/downloads/?f=LHAPDF-6.5.5.tar.gz" -o LHAPDF-6.5.5.tar.gz
tar xzf LHAPDF-6.5.5.tar.gz
cd LHAPDF-6.5.5
setenv LHAPDF_PREFIX ${GENIE_BASE}/install/lhapdf-6.5.5
./configure --prefix=${LHAPDF_PREFIX} --disable-python CC=${CC} CXX=${CXX} | & tee ${GENIE_BASE}/logs/lhapdf-configure.log
make -j ${NCPU} | & tee ${GENIE_BASE}/logs/lhapdf-build.log
make install | & tee ${GENIE_BASE}/logs/lhapdf-install.log
setenv LHAPDF_PREFIX ${GENIE_BASE}/install/lhapdf-6.5.5
setenv LHAPDF_INC `${LHAPDF_PREFIX}/bin/lhapdf-config --incdir`
setenv LHAPDF_LIB `${LHAPDF_PREFIX}/bin/lhapdf-config --libdir`
setenv PATH ${LHAPDF_PREFIX}/bin:${PATH}
setenv LD_LIBRARY_PATH ${LHAPDF_LIB}:${LD_LIBRARY_PATH}
setenv LHAPDF_DATA_PATH ${LHAPDF_PREFIX}/share/LHAPDF
nano ${GENIE_BASE}/setup_genie.csh
source ${GENIE_BASE}/setup_genie.csh
rehash
cd ${GENIE}
./configure --prefix=${GENIE_INSTALL} --enable-gsl --enable-flux-drivers --enable-geom-drivers --enable-rwght --disable-lhapdf5 --enable-lhapdf6 --with-lhapdf6-lib=${LHAPDF_LIB} --with-lhapdf6-inc=${LHAPDF_INC} --with-optimiz-level=O2 --with-pythia6-lib=${PYTHIA6}/lib --with-pythia6-inc=${PYTHIA6}/inc --with-log4cpp-lib=${LOG4CPP_PREFIX}/lib --with-log4cpp-inc=${LOG4CPP_PREFIX}/include --with-libxml2-lib=${XML2_PREFIX}/lib --with-libxml2-inc=${XML2_PREFIX}/include/libxml2 --with-gsl-lib=${GSL_PREFIX}/lib --with-gsl-inc=${GSL_PREFIX}/include | & tee ${GENIE_BASE}/logs/genie-configure.log
make -j ${NCPU} | & tee ${GENIE_BASE}/logs/genie-build.log
make install | & tee ${GENIE_BASE}/logs/genie-install.log
rehash
which gevgen
which gmkspl
source ${GENIE_BASE}/setup_genie.csh
mkdir -p ${GENIE_BASE}/production/rgm_lar_e5986
cd ${GENIE_BASE}/production/rgm_lar_e5986
gmkspl -p 11 -t 1000180400 -n 250 -e 6.2 -o e_Ar40_G18_02a_00_000.xml --tune G18_02a_00_000 --event-generator-list EM | & tee gmkspl_e_Ar40.log
gevgen -r 0 -n 5000 -p 11 -t 1000180400 -e 5.98636 --event-generator-list EM --tune G18_02a_00_000 --cross-sections e_Ar40_G18_02a_00_000.xml --seed 1000000 -o rgm_eAr_5p98636GeV_test |& tee gevgen_test.log
gntpc -i rgm_eAr_5p98636GeV_test -f gst -o rgm_eAr_5p98636GeV_test.gst.root





