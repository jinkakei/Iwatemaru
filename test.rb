
require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

# cut
=begin
in_fn = "interpolated.nc"
  lon_min = 142.2; lon_max = 142.4
  gp_cptemp0   = GPhys::IO.open( in_fn, "cptemp")
    gp_cptemp = gp_cptemp0.cut( "lon" => lon_min..lon_max )
  gp_csal0   = GPhys::IO.open( in_fn, "csal")
    gp_csal = gp_csal0.cut( "lon" => lon_min..lon_max )
  gp_crhoo0  = GPhys::IO.open( in_fn, "crhoo")
    gp_crhoo = gp_crhoo0.cut( "lon" => lon_min..lon_max )
  p gp_cptemp.val
  DCL.gropn( 1 ) # 1: display, 2: pdf
  #dcl.udpset( 'lmsg', false ) # erase "contour interval ..."
    tlevs = 1.0 * NArray.sfloat( 18 ).indgen + 2.0
    GGraph.tone( gp_cptemp, true, "levels"=> tlevs )
    slevs = 0.1 * NArray.sfloat( 11 ).indgen + 33.0
    GGraph.tone( gp_csal, true, "levels"=> slevs )
    rlevs = 0.2 * NArray.sfloat( 16 ).indgen + 23.8 # 23.8 ~ 26.7
    GGraph.tone( gp_crhoo, true, "levels"=> rlevs )
  DCL.grcls
# 2016-06-15: caution! tentative, rhoo -> temp ( for current nhmodel.F)
  temp = 10.0 + ( gp_crhoo.val - 25.25 ) * 0.001 / ( - 2.0 * 0.0001)
  #p temp
  #p temp.max
  #p temp.min
=end


# for report
#=begin
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
  #for t in 0..nt-1
  for t in 0..1
    GGraph.tone( gp_sal.cut( "time" => time_arr[t] ), true, "levels"=> slevs )
  end
  DCL.grcls
#=end
