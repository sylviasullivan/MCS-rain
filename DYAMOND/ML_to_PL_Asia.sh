#Build a command to remap the model level output to the pressure levels
# given in PMEAN_*-*.txt

# Directory and inputs to build the file names.
basedir='/xdisk/sylvia/DYAMOND-UM/'
file_prefixes=("wa" "ta" "hus" "cli" "clw")
filesuffix='_3hr_HadGEM3-GA71_N2560_20160801-20160908_Asia.nc'
for fileprefix in "${file_prefixes[@]}"; do
    inputfile=$basedir$fileprefix$filesuffix
    echo $file

    # Read the pressure levels from the txt file. Add them line by line to $pressures.
    # c counts how many pressures are specified.
    c=0
    pressures=
    pfull_mean='/groups/sylvia/JAS-MCS-rain/DYAMOND/mean_pfull_3hr_HadGEM3-GA71_N2560_20160801-20160908_Asia.txt'
    while read -r line; do pressures=$pressures$line','; c=$((c+1)); done < $pfull_mean
          echo $c' pressures specified'

    # Remove the last comma from $pressures.
    pressures="${pressures%?}"
    echo $pressures

    # Assemble the filenames and command.
    part1='cdo ml2pl,'
    outputfile=$basedir$fileprefix'_3hr_HadGEM3-GA71_N2560_20160801-20160908_Asia_PLfull.nc'

    # Rename pres as air_pressure in the $inputfile.
    #cdo chname,pres,air_pressure $inputfile $basedir'temp.nc'
    cmd=$part1$pressures' '$inputfile' '$outputfile
    echo ${cmd}

    # Evaluate the command as you would from the command line.
    eval $cmd

    # Read the pressure levels from the txt file. Add them line by line to $pressures.
    # c counts how many pressures are specified.
    c=0
    pressures=
    phalf_mean='/groups/sylvia/JAS-MCS-rain/DYAMOND/mean_phalf_3hr_HadGEM3-GA71_N2560_20160801-20160908_Asia.txt'
    while read -r line; do pressures=$pressures$line','; c=$((c+1)); done < $phalf_mean
          echo $c' pressures specified'

    # Remove the last comma from $pressures.
    pressures="${pressures%?}"
    echo $pressures

    # Assemble the filenames and command.
    part1='cdo ml2pl,'
    outputfile=$basedir$fileprefix'_3hr_HadGEM3-GA71_N2560_20160801-20160908_Asia_PLhalf.nc'

    # Rename pres as air_pressure in the $inputfile.
    #cdo chname,pres,air_pressure $inputfile $basedir'temp.nc'
    cmd=$part1$pressures' '$inputfile' '$outputfile
    echo ${cmd}

    # Evaluate the command as you would from the command line.
    eval $cmd
done
