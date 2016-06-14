
require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

# cut
in_fn = "interpolated.nc"
  gp_cptemp0   = GPhys::IO.open( in_fn, "cptemp")
    gp_cptemp = gp_cptemp0.cut( "lon" => 142.2..142.5 )
  gp_csal0   = GPhys::IO.open( in_fn, "csal")
    gp_csal = gp_csal0.cut( "lon" => 142.2..142.5 )
  gp_crhoo0  = GPhys::IO.open( in_fn, "crhoo")
    gp_crhoo = gp_crhoo0.cut( "lon" => 142.2..142.5 )

  DCL.gropn( 1 ) # 1: display, 2: pdf
  #dcl.udpset( 'lmsg', false ) # erase "contour interval ..."
    tlevs = 1.0 * NArray.sfloat( 18 ).indgen + 2.0
    GGraph.tone( gp_cptemp, true, "levels"=> tlevs )
    slevs = 0.1 * NArray.sfloat( 11 ).indgen + 33.0
    GGraph.tone( gp_csal, true, "levels"=> slevs )
    rlevs = 0.1 * NArray.sfloat( 29 ).indgen + 23.9
    GGraph.tone( gp_crhoo, true, "levels"=> rlevs )
  DCL.grcls

# for report
=begin
in_fn = "clim.nc"
  gp_csal   = GPhys::IO.open( in_fn, "csal")
  gp_sal  =  GPhys::IO.open( in_fn, "sal")
    time_arr = gp_sal.coord( 2 ).val; nt = time_arr.length
    p gp_sal.max
    p gp_sal.min

  DCL.gropn( 1 ) # 1: display, 2: pdf
  #dcl.udpset( 'lmsg', false ) # erase "contour interval ..."
    slevs = 0.1 * NArray.sfloat( 31 ).indgen + 32.4
    stlevs = 0.1 * NArray.sfloat( 11 ).indgen + 33.0
    #GGraph.tone( gp_csal, true, "levels"=> slevs )
    GGraph.tone( gp_sal.cut( "time" => time_arr[0] ), true, "levels"=> stlevs )
  DCL.grcls
=end
