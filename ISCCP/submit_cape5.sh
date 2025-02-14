#!/bin/sh
#SBATCH --job-name=cape5_iterate
#SBATCH --account=sylvia
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --output=/xdisk/sylvia/ERA_logs/capelog_%j.out
#SBATCH --error=/xdisk/sylvia/ERA_logs/capelog_%j.out
#SBATCH --time=6:00:00
#SBATCH --mem=50gb
#SBATCH --nodes=1
#SBATCH --ntasks=6

#source activate era5

for year in 2004; do
    for month in 4 5 6 7 8 9 10 11 12; do
        echo Starting for year $year and month $month

        # Dynamically handle single-digit and double-digit months
        if [ "$month" -lt 10 ]; then
            formatted_month="0$month"
        else
            formatted_month="$month"
        fi

        cat > ERA5_CAPERetrieve.py <<EOL
import cdsapi
c = cdsapi.Client()
c.retrieve(
    'reanalysis-era5-single-levels',
    {
        'product_type':'reanalysis',
        'variable':'convective_available_potential_energy',
        'year':'${year}',
        'month':'${formatted_month}',
        'day':['01','02','03','04','05','06','07',
               '08','09','10','11','12','13','14',
               '15','16','17','18','19','20','21',
               '22','23','24','25','26','27','28',
               '29','30','31'],
        'time':[
            '00:00','03:00','06:00',
            '09:00','12:00','15:00',
            '18:00','21:00'],
        'area':'10/-180/-10/180',
        'format':'netcdf'
    },
 '/xdisk/sylvia/ERA5_output/ERA5_cape_tropical.nc')
EOL

    sbatch --wait --output=/dev/null /groups/sylvia/JAS-MCS-rain/ISCCP/submit_CAPE5request.sh
    # Wait until this job is done

    python collocate_ERA5_2D.py ${year} ${month} 'cape'
  done
done
