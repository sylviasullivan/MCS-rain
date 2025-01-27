#!/bin/sh
#SBATCH --job-name=qi5_iterate
#SBATCH --account=sylvia
#SBATCH --partition=high_priority
#SBATCH --qos=user_qos_sylvia
#SBATCH --output=/xdisk/sylvia/ERA_logs/qilog_%j.out
#SBATCH --error=/xdisk/sylvia/ERA_logs/qilog_%j.out
#SBATCH --time=14:00:00
#SBATCH --mem=50gb
#SBATCH --nodes=1
#SBATCH --ntasks=28

source activate era5

for year in 1983; do
#1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008; do
    for month in 8 9 10 11 12; do
        echo Starting for year $year

        # Dynamically handle single-digit and double-digit months
        if [ "$month" -lt 10 ]; then
            formatted_month="0$month"
        else
            formatted_month="$month"
        fi
        
        cat > ERA5_QIRetrieve.py <<EOL
import cdsapi
c = cdsapi.Client()
c.retrieve(
    'reanalysis-era5-pressure-levels',
    {
        'product_type':'reanalysis',
        'variable':'specific_cloud_ice_water_content',
        'pressure_level':['125','150','175','200','225',
                          '250','300','350','400','450',
                          '500','550','600','650','700',
                          '750','775','800','825','850',
                          '875','900','925','950','975',
                          '1000'],
        'year':${year},
        'month':'${formatted_month}',
        'day':['01','02','03','04','05','06','07','08','09',
               '10','11','12','13','14','15','16','17','18',
               '19','20','21','22','23','24','25','26','27',
               '28','29','30','31'],
        'time':[
            '00:00','01:00','02:00',
            '03:00','04:00','05:00',
            '06:00','07:00','08:00',
            '09:00','10:00','11:00',
            '12:00','13:00','14:00',
            '15:00','16:00','17:00',
            '18:00','19:00','20:00',
            '21:00','22:00','23:00'],
        'area':'10/-180/-10/180',
        'format':'netcdf'
    },
 './ERA5_qi_tropical.nc')
EOL

    sbatch --wait --output=/dev/null /groups/sylvia/JAS-MCS-rain/ISCCP/submit_QI5request.sh
    # Wait until this job is done

    python collocate_ERA5.py ${year} ${month} 'qi'
  done
done

