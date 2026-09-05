#!/bin/bash

for ((i = 0; i < 1000; i++)); do

  slurmSubScriptFName="slurm_gibuu_Gen_${i}.sh"

  dirName="dir_${i}"

  mkdir -p "${dirName}"
  cd "${dirName}"

  cat > "${slurmSubScriptFName}" <<EOF
#!/bin/bash
#SBATCH --job-name=gibuu_${i}
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
 
SEED=$((15780000 + i))

cp /volatile/clas12/jahmed/gibuu_local/cards/eAr_5986_RGM.job  eAr_5986_RGM_seed.job
sed -E -i "s/^([[:space:]]*)SEED[[:space:]]*=[[:space:]]*[0-9]+/\1SEED = \${SEED}/" eAr_5986_RGM_seed.job

echo "Job index: ${i}"
echo "Seed: \${SEED}"
echo "Host: \$(hostname)"
echo "Start time: \$(date)"
/work/clas12/jahmed/gibuu_local/release/testRun/GiBUU.x < eAr_5986_RGM_seed.job |& tee gibuu_test.log
/lustre24/expphy/volatile/clas12/jahmed/gibuu_local/gibuu2lund_2025 -1
echo "End time: \$(date)"
 
EOF

  sbatch $slurmSubScriptFName
  cd ..
done

