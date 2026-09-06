#!/bin/bash

for ((i = 0; i < 1000; i++)); do

  slurmSubScriptFName="slurm_genie_Gen_${i}.sh"

  dirName="dir_${i}"

  mkdir -p "${dirName}"
  cd "${dirName}"

  cat > "${slurmSubScriptFName}" <<EOF
#!/bin/bash
#SBATCH --job-name=genie_${i}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2048M
#SBATCH --gres=disk:5G
#SBATCH --partition=production
#SBATCH --account=clas12
#SBATCH --time=23:00:00
#SBATCH --output=slurm_${i}.out
#SBATCH --error=slurm_${i}.err

 
SEED=$((1000000 + i))


echo "Job index: ${i}"
echo "Seed: \${SEED}"
echo "Host: \$(hostname)"
echo "Start time: \$(date)"
gevgen -r ${i} -n 100000 -p 11 -t 1000180400 -e 5.98636 --event-generator-list EM --tune G18_02a_00_000 --cross-sections ../e_Ar40_G18_02a_00_000.xml --seed \${SEED} -o rgm_eAr_5p98636GeV |& tee gevgen.log
gntpc -i rgm_eAr_5p98636GeV -f gst -o rgm_eAr_5p98636GeV.gst.root
/w/hallb-scshelf2102/clas12/jahmed/genie-local/genie2lund -1
echo "End time: \$(date)"
 
EOF

  sbatch $slurmSubScriptFName
  cd ..
done
