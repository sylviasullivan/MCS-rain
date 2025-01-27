#!/bin/sh
#SBATCH --account=sylvia
#SBATCH --job-name=qv5_download
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --output=/xdisk/sylvia/ERA_logs/qvlog_%j.out
#SBATCH --error=/xdisk/sylvia/ERA_logs/qvlog_%j.out
#SBATCH --time=01:15:00
#SBATCH --mem=50gb
#SBATCH --nodes=2
#SBATCH --ntasks=28

#source activate era5
python /groups/sylvia/JAS-MCS-rain/ISCCP/ERA5_QVRetrieve.py

