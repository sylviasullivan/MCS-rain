#!/bin/sh
#SBATCH
#SBATCH --account=sylvia
#SBATCH --job-name=cape5_download
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --output=/xdisk/sylvia/ERA_logs/log_%j.out
#SBATCH --error=/xdisk/sylvia/ERA_logs/log_%j.out
#SBATCH --time=00:30:00
#SBATCH --mem=50gb
#SBATCH --nodes=1
#SBATCH --ntasks=12

source activate era5
python /groups/sylvia/JAS-MCS-rain/ISCCP/ERA5_CAPERetrieve.py
