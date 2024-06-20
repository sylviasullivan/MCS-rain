# environmental_T is a profile of environmental temperatures over pressure levels plev [K]
# environmental_qv is a profile of environmental water vapor mass mixing ratios over pressure levels plev [kg kg-1]
# plev is an input vertical profile of pressures [Pa]
# epsilon is a prescribed (and constant) entrainment rate

def zero_buoyancy_plume_plev( environmental_T, environmental_qv, plev, epsilon ):
    from scipy.integrate import simps
    from thermodynamic_functions import satMR_liq
    
    g = 9.8 # gravitational acceleration [m s-2]
    Lv = 2260*10**3 # latent heat of vaporization for water vapor [J kg-1]
    cp = 4200 # heat capacity for water vapor [J kg-1 K-1]
    Rv = 461.5 # specific gas constant for water vapor [J kg-1 K-1]
    
    environmental_qvsat = satMR_liq( environmental_T, plev )
    SD = environmental_qvsat - environmental_qv
    
    term1 = epsilon * Lv / cp * simps( x=plev, y=SD )
    term2 = 1 + Lv**2 * environmental_qvsat / (Rv * environmental_T**2 * cp)
    delta_temperature = term1 / term2
    buoyancy = g * delta_temperature / environmental_T
    CAPE = simps( x=plev, y=buoyancy )
    return CAPE, buoyancy

# as above but now integrate over altitudes not pressure levels
# environmental_p is a profile of environmental pressures over altidues [Pa]
# altitudes is an input vertical profile of altitudes [m]
def zero_buoyancy_plume_alt( environmental_T, environmental_qv, environmental_p, altitudes, epsilon ):
    from scipy.integrate import simps
    from thermodynamic_functions import satMR_liq
    
    g = 9.8 # gravitational acceleration [m s-2]
    Lv = 2260*10**3 # latent heat of vaporization for water vapor [J kg-1]
    cp = 4200 # heat capacity for water vapor [J kg-1 K-1]
    Rv = 461.5 # specific gas constant for water vapor [J kg-1 K-1]
    
    environmental_qvsat = satMR_liq( environmental_T, environmental_p )
    SD = environmental_qvsat - environmental_qv
    
    term1 = epsilon * Lv / cp * simps( x=altitudes, y=SD )
    term2 = 1 + Lv**2 * environmental_qvsat / (Rv * environmental_T**2 * cp)
    delta_temperature = term1 / term2
    buoyancy = g * delta_temperature / environmental_T
    CAPE = simps( x=altitudes, y=buoyancy )
    return CAPE, buoyancy

def CAPEdiff( epsilon, evaluation_field, nbin, sdupper, sd_in, pc2, T_in, qv_in, P_in, altitudes ):
    import numpy as np
    from plotting_utilities import bin_stat_function
    
    CAPE_zbp = np.empty( T_in.shape[0] )
    for i in np.arange( T_in.shape[0] ):
        CAPE_zbp[i], _ = zero_buoyancy_plume_alt( T_in[i], qv_in[i]*1e-3, P_in[i]*1e2, altitudes, epsilon=epsilon )

    sd_bins_zbp, _, _, cape99_vals_zbp, _, _, _, _ = \
        bin_stat_function( nbin, 0, sdupper, sd_in, CAPE_zbp, pc2=pc2, threshold=10 )
    
    # using indices 5-17 here because that is where the tracking data roughly correlates positively
    return np.nansum( (cape99_vals_zbp[1:16] - evaluation_field[1:16])**2 )


def tune_entrainment( epsilon_range, evaluation_field, nbin, sdupper, sd_in, pc2, T_in, qv_in, P_in, altitudes ):
    results = []
    for epsilon in epsilon_range:
        result = CAPEdiff( epsilon, evaluation_field, nbin, sdupper, sd_in, pc2, T_in, qv_in, P_in, altitudes )
        results.append( (epsilon, result) )
    return results