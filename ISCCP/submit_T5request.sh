#!/bin/sh
#SBATCH --account=sylvia
#SBATCH --job-name=T5_download
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --time=00:30:00
#SBATCH --mem=50gb
#SBATCH --nodes=2
#SBATCH --ntasks=28

#source activate era5
python /groups/sylvia/JAS-MCS-rain/ISCCP/ERA5_TRetrieve.py

#--output=/xdisk/sylvia/ERA_logs/Tlog_%j.out
#--error=/xdisk/sylvia/ERA_logs/Tlog_%j.out
