#!/bin/bash

#SBATCH -p cpu3 #GPU1/GPU2/GPU3
#SBATCH -N 1-1  # 只在一个节点上运行
#SBATCH -n 1
#SBATCH -c 20  # CPUs per task      1
#SBATCH --mem 30720  # memory limit
#SBATCH -o slurm-%j.stdout  # STDOUT 
#SBATCH -e slurm-%j.stderr  # STDERR


module load matlab/R2018b

srun matlab -nodisplay -nosplash -nodesktop -r "run('main.m'); exit;"
