#!/bin/sh
#SBATCH --job-name=qv5_iterate
#SBATCH --account=sylvia
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --output=/xdisk/sylvia/ERA_logs/qvlog_%j.out
#SBATCH --error=/xdisk/sylvia/ERA_logs/qvlog_%j.out
#SBATCH --time=4444:00:00
#SBATCH --mem=50gb
#SBATCH --nodes=1
#SBATCH --ntasks=28

#source activate era5

for year in 2000; do
    for month in 1; do
        echo Starting for year $year and month $month

        # Dynamically handle single-digit and double-digit months
        if [ "$month" -lt 10 ]; then
            formatted_month="0$month"
        else
            formatted_month="$month"
        fi
        
        cat > ERA5_QVRetrieve.py <<EOL
import cdsapi
c = cdsapi.Client()
c.retrieve(
    'reanalysis-era5-pressure-levels',
    {
        'product_type':'reanalysis',
        'variable':'specific_humidity',
        'pressure_level':['125','150','175','200','225',
                          '250','300','350','400','450',
                          '500','550','600','650','700',
                          '750','775','800','825','850',
                          '875','900','925','950','975',
                          '1000'],
        'year':${year},
        'month':'${formatted_month}',
        'day':[ '01','02','03','04','05','06','07','08','09',
               '10','11','12','13','14','15','16','17','18',
               '19','20','21','22','23','24','25','26','27',
               '28','29','30','31' ],
        'time':[ '00:00','03:00','06:00',
                 '09:00','12:00','15:00',
                 '18:00','21:00' ],
        'area':'10/-180/-10/180',
        'format':'netcdf'
    },
 '/xdisk/sylvia/ERA5_output/ERA5_qv_tropical.nc')
EOL

    sbatch --wait --output=/dev/null /groups/sylvia/JAS-MCS-rain/ISCCP/submit_QV5request.sh
    # Wait until this job is done

    python collocate_ERA5_vectorized.py ${year} ${month} 'qv'
  done
done
