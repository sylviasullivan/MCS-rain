import cdsapi
c = cdsapi.Client()
c.retrieve(
    'reanalysis-era5-single-levels',
    {
        'product_type':'reanalysis',
        'variable':[ 'total_precipitation', 'convective_rain_rate' ],
        'year':'2000',
        'month':'01',
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
 '/xdisk/sylvia/ERA5_output/ERA5_precip_tropical.nc')
