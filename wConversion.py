# Input a vertical velocity [m s-1] from RCE sims
# Output a pressure velocity [Pa s-1]
# See this page: https://www.sjsu.edu/faculty/watkins/omega.htm
# This conversion assumes hydrostasy

def wConversion( w_velocity ):
    rho_air = 1.3  # [kg m-3 air] Technically this should account for altitude dependence
    g       = 9.8  # [m s-2] Gravitational acceleration

    # Calculate pressure velocity
    omega = -rho_air * g * w_velocity
    return omega
