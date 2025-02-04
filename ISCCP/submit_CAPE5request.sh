#!/bin/sh
#SBATCH
#SBATCH --account=sylvia
#SBATCH --job-name=cape5_download
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --time=00:30:00
#SBATCH --mem=50gb
#SBATCH --nodes=1
#SBATCH --ntasks=12

source activate era5
python /groups/sylvia/JAS-MCS-rain/ISCCP/ERA5_CAPERetrieve.py
#--output=/xdisk/sylvia/ERA_logs/capelog_%j.out
#--error=/xdisk/sylvia/ERA_logs/capelog_%j.out

