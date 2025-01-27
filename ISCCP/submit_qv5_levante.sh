#!/bin/sh
#SBATCH --job-name=qv5_iterate
#SBATCH --account=bb1430
#SBATCH --partition=compute
#SBATCH --output=/work/bb1163/b380873/logs/era5/qvlog_%j.out
#SBATCH --error=/work/bb1163/b380873/logs/era5/qvlog_%j.out
#SBATCH --time=6:00:00
#SBATCH --mem=50gb
#SBATCH --nodes=1
#SBATCH --ntasks=10

#source activate era5

for year in 1983; do
    for month in 9 10 11 12; do
        echo Starting for year $year

    python collocate_ERA5_vectorized.py ${year} ${month} 'qv'
  done
done
