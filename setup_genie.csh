#!/bin/tcsh

setenv GENIE_BASE /work/clas12/$USER/genie-local
setenv GENIE_VERSION R-3_06_02

setenv GSL_PREFIX ${GENIE_BASE}/install/gsl-2.8
setenv XML2_PREFIX ${GENIE_BASE}/install/libxml2-2.12.10
setenv LOG4CPP_PREFIX ${GENIE_BASE}/install/log4cpp-1.1.4
setenv PYTHIA6 ${GENIE_BASE}/src/pythia6/v6_428
setenv ROOT_PREFIX ${GENIE_BASE}/install/root-6.30.08

setenv GENIE ${GENIE_BASE}/src/Generator-${GENIE_VERSION}
setenv GENIE_INSTALL ${GENIE_BASE}/install/genie-${GENIE_VERSION}

setenv LHAPDF_PREFIX ${GENIE_BASE}/install/lhapdf-6.5.5
setenv LHAPDF_INC ${LHAPDF_PREFIX}/include
setenv LHAPDF_LIB ${LHAPDF_PREFIX}/lib

source ${ROOT_PREFIX}/bin/thisroot.csh

setenv PATH ${GSL_PREFIX}/bin:${XML2_PREFIX}/bin:${GENIE_INSTALL}/bin:${PATH}
setenv PATH ${LHAPDF_PREFIX}/bin:${PATH}

if ( $?LD_LIBRARY_PATH ) then
    setenv LD_LIBRARY_PATH ${GENIE_INSTALL}/lib:${GSL_PREFIX}/lib:${XML2_PREFIX}/lib:${LOG4CPP_PREFIX}/lib:${PYTHIA6}/lib:${LHAPDF_LIB}:${LD_LIBRARY_PATH}
else
    setenv LD_LIBRARY_PATH ${GENIE_INSTALL}/lib:${GSL_PREFIX}/lib:${XML2_PREFIX}/lib:${LOG4CPP_PREFIX}/lib:${PYTHIA6}/lib:${LHAPDF_LIB}
endif

if ( $?PKG_CONFIG_PATH ) then
    setenv PKG_CONFIG_PATH ${GSL_PREFIX}/lib/pkgconfig:${XML2_PREFIX}/lib/pkgconfig:${LOG4CPP_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}
else
    setenv PKG_CONFIG_PATH ${GSL_PREFIX}/lib/pkgconfig:${XML2_PREFIX}/lib/pkgconfig:${LOG4CPP_PREFIX}/lib/pkgconfig
endif

setenv GSL_INC ${GSL_PREFIX}/include
setenv GSL_LIB ${GSL_PREFIX}/lib

setenv LOG4CPP_INC ${LOG4CPP_PREFIX}/include
setenv LOG4CPP_LIB ${LOG4CPP_PREFIX}/lib

setenv LIBXML2_INC `${XML2_PREFIX}/bin/xml2-config --cflags`
setenv LIBXML2_LIB `${XML2_PREFIX}/bin/xml2-config --libs`

setenv PYTHIA6_INC ${PYTHIA6}/inc
setenv PYTHIA6_LIB ${PYTHIA6}/lib

setenv LHAPDF_DATA_PATH ${LHAPDF_PREFIX}/share/LHAPDF

setenv GENIE_REWEIGHT $GENIE

