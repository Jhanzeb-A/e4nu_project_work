#!/bin/bash

for ((i = 0; i < 1000; i++)); do

  slurmSubScriptFName="slurm_gibuu_gemc_${i}.sh"
  dirName="dir_${i}"

  mkdir -p "${dirName}"
  cd "${dirName}"

  cat > "${slurmSubScriptFName}" <<EOF
#!/bin/bash
#SBATCH --job-name=gibuu_gemc_${i}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2048M
#SBATCH --gres=disk:5G
#SBATCH --partition=production
#SBATCH --account=clas12
#SBATCH --time=23:00:00
#SBATCH --output=slurm_${i}.out
#SBATCH --error=slurm_${i}.err

module use /cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/sw/modulefiles
module load clas12
 
GCARD=/lustre24/expphy/volatile/clas12/jahmed/gibuu_local/cards/rgm_fall2021_Ar.gcard
RUNNO=15802
LUNDFILE=/lustre24/expphy/volatile/clas12/jahmed/gibuu_local/gen/bulk1/dir_${i}/gibuu.dat

echo "Job index: ${i}"
echo "Host: \$(hostname)"
echo "Start time: \$(date)"
gemc "\$GCARD" -RUNNO="\$RUNNO" -USE_GUI=0 -INPUT_GEN_FILE="LUND, \$LUNDFILE" -OUTPUT="hipo,gemc_gibuu_OutFile.hipo"
echo "End time: \$(date)"
 
EOF

  sbatch $slurmSubScriptFName
  cd ..
done

