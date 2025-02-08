#!/bin/sh
#SBATCH
#SBATCH --account=sylvia
#SBATCH --job-name=pacc5_download
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --time=00:30:00
#SBATCH --mem=50gb
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --output=/xdisk/sylvia/ERA_logs/pacclog_%j.out
#SBATCH --error=/xdisk/sylvia/ERA_logs/pacclog_%j.out

#source activate era5
python /groups/sylvia/JAS-MCS-rain/ISCCP/ERA5_PACCRetrieve.py
#--output=/xdisk/sylvia/ERA_logs/capelog_%j.out
#--error=/xdisk/sylvia/ERA_logs/capelog_%j.out

