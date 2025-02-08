#!/bin/sh
#SBATCH
#SBATCH --account=sylvia
#SBATCH --job-name=precip5_download
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --time=00:30:00
#SBATCH --mem=50gb
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --output=/xdisk/sylvia/ERA_logs/preciplog_%j.out
#SBATCH --error=/xdisk/sylvia/ERA_logs/preciplog_%j.out

#source activate era5
python /groups/sylvia/JAS-MCS-rain/ISCCP/ERA5_PRECIPRetrieve.py
#--output=/xdisk/sylvia/ERA_logs/capelog_%j.out
#--error=/xdisk/sylvia/ERA_logs/capelog_%j.out

