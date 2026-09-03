#!/bin/tcsh

module use /cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/sw/modulefiles
module load clas12
mkdir -p /work/clas12/$USER/gibuu_local
mkdir -p /volatile/clas12/$USER/gibuu_local
cd /work/clas12/$USER/gibuu_local
wget --content-disposition 'https://gibuu.hepforge.org/downloads?f=release2025.tar.gz'
wget --content-disposition 'https://gibuu.hepforge.org/downloads?f=buuinput2025.tar.gz'
tar -xzf release2025.tar.gz
tar -xzf buuinput2025.tar.gz
cd /work/clas12/$USER/gibuu_local/release
make -j8 FORT=gfortran
cd /work/clas12/$USER/gibuu_local
wget --content-disposition 'https://gibuu.hepforge.org/downloads?f=libraries2025_RootTuple.tar.gz'
tar -xzf libraries2025_RootTuple.tar.gz
cd release
make renew
make buildRootTuple
make -j8 withROOT=1 FORT=gfortran
cd /work/clas12/$USER/gibuu_local/release
find testRun/jobCards -type f | sort
mkdir -p /volatile/clas12/$USER/gibuu_local/cards
cp testRun/jobCards/005_inclusive_eA.job /volatile/clas12/$USER/gibuu_local/cards/eAr_5986_RGM.job
nano  /volatile/clas12/$USER/gibuu_local/cards/eAr_5986_RGM.job 
mkdir -p /volatile/clas12/$USER/gibuu_local/test_gibuu
cd /volatile/clas12/$USER/gibuu_local/test_gibuu
/work/clas12/$USER/gibuu_local/release/testRun/GiBUU.x < ../cards/eAr_5986_RGM.job
