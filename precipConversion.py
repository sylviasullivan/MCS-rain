# Input a rain mass mixing ratio [g kg-1] from RCE sims
# Output a rain rate [mm h-1] corresponding to RCE sim resolutions

def precipConversion( qp ):
    rho_air = 1.3  # [kg m-3 air] Technically this should account for altitude dependence
    rho_liq = 1000 # [kg m-3 liq water / rain]
    del_t   = 0.5  # [h] Temporal resolution of the RCE sims
    del_x   = 3000 # [m] Spatial resolution of the RCE sims

    # Calculate rain rate [m h-1] and return a value in [mm h-1]
    rr = qp * rho_air / rho_liq / del_t * del_x**2
    return rr / 1000
