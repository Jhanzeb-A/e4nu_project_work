#!/bin/bash

for ((i = 0; i < 1000; i++)); do

  slurmSubScriptFName="slurm_genie_gemc_${i}.sh"
  dirName="dir_${i}"

  mkdir -p "${dirName}"
  cd "${dirName}"

  cat > "${slurmSubScriptFName}" <<EOF
#!/bin/bash
#SBATCH --job-name=genie_gemc_${i}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=2048M
#SBATCH --gres=disk:5G
#SBATCH --partition=production
#SBATCH --account=clas12
#SBATCH --time=24:00:00
#SBATCH --output=slurm_${i}.out
#SBATCH --error=slurm_${i}.err

module use /cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/sw/modulefiles
module load clas12
 
GCARD=/lustre24/expphy/volatile/clas12/jahmed/genie_local/cards/rgm_fall2021_Ar.gcard
RUNNO=15802
LUNDFILE=/lustre24/expphy/volatile/clas12/jahmed/genie_local/gen/bulk1/dir_${i}/rgm_eAr_5p98636GeV_test_lund.dat

echo "Job index: ${i}"
echo "Host: \$(hostname)"
echo "Start time: \$(date)"
echo "Allocated CPUs: \$SLURM_CPUS_PER_TASK"

mkdir -p gemc_part0_work gemc_part1_work

cd gemc_part0_work 

gemc "\$GCARD" -RUNNO="\$RUNNO" -USE_GUI=0 -N=10000 -SKIPNGEN=0 -INPUT_GEN_FILE="LUND, \$LUNDFILE" -OUTPUT="hipo,gemc_genie_part0.hipo" > gemc_part0.log 2>&1 &

PID0=\$!

cd ../gemc_part1_work

gemc "\$GCARD" -RUNNO="\$RUNNO" -USE_GUI=0 -N=20000 -SKIPNGEN=10000 -INPUT_GEN_FILE="LUND, \$LUNDFILE" -OUTPUT="hipo,gemc_genie_part1.hipo" > gemc_part1.log 2>&1 &

PID1=\$!

cd ..

echo "GEMC process 0 PID: \$PID0"
echo "GEMC process 1 PID: \$PID1"

wait \$PID0
STATUS0=\$?
 
wait \$PID1
STATUS1=\$?

echo "GEMC part 0 exit status: \$STATUS0"
echo "GEMC part 1 exit status: \$STATUS1"

echo "End time: \$(date)"

if [[ \$STATUS0 -ne 0 || \$STATUS1 -ne 0 ]]; then
    echo "ERROR: At least one GEMC process failed."
    exit 1
fi

hipo-utils -merge -o gemc_genie_OutFile.hipo gemc_part0_work/gemc_genie_part0.hipo gemc_part1_work/gemc_genie_part1.hipo

touch success.txt
 
EOF

  sbatch $slurmSubScriptFName
  cd ..
done

