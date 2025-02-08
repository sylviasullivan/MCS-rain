#!/bin/sh
#SBATCH --account=sylvia
#SBATCH --job-name=w5_download
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --time=00:45:00
#SBATCH --mem=50gb
#SBATCH --nodes=2
#SBATCH --ntasks=28

#source activate era5
python /groups/sylvia/JAS-MCS-rain/ISCCP/ERA5_WRetrieve.py

#--output=/xdisk/sylvia/ERA_logs/wlog_%j.out
#--error=/xdisk/sylvia/ERA_logs/wlog_%j.out

