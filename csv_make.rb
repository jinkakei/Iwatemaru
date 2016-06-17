
require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

# cut
in_fn = "clim_lin.nc"
  #lon_min = 142.2; lon_max = 142.5
  lon_min = 142.1; lon_max = 142.5025
  gp_cptemp0   = GPhys::IO.open( in_fn, "cptemp_lin")
    gp_cptemp = gp_cptemp0.cut( "llon" => lon_min..lon_max )
  gp_csal0   = GPhys::IO.open( in_fn, "csal_lin")
    gp_csal = gp_csal0.cut( "llon" => lon_min..lon_max )
  gp_crhoo0  = GPhys::IO.open( in_fn, "crhoo_lin")
    gp_crhoo = gp_crhoo0.cut( "llon" => lon_min..lon_max )
  xn, yn = gp_cptemp.shape
  #DCL.gropn( 1 ) # 1: display, 2: pdf
  ##dcl.udpset( 'lmsg', false ) # erase "contour interval ..."
  #  tlevs = 1.0 * NArray.sfloat( 18 ).indgen + 2.0
  #  GGraph.tone( gp_cptemp, true, "levels"=> tlevs )
  #  slevs = 0.1 * NArray.sfloat( 11 ).indgen + 33.0
  #  GGraph.tone( gp_csal, true, "levels"=> slevs )
  #  rlevs = 0.2 * NArray.sfloat( 16 ).indgen + 23.8 # 23.8 ~ 26.7
  #  GGraph.tone( gp_crhoo, true, "levels"=> rlevs )
  #DCL.grcls
# 2016-06-15: caution! tentative, rhoo -> temp ( for current nhmodel.F)
  #temp = 10.0 + ( gp_crhoo.val - 25.25 ) * 0.001 / ( - 2.0 * 0.0001)
  #p temp
  #p temp.max
  #p temp.min
# 2016-06-16
  cptemp = gp_cptemp.val
  csal   = gp_csal.val
  out_fn = "clim_lin.csv"
    puts "out_fn: #{out_fn}"
    puts "  xn = #{xn}, yn = #{yn}"
  fu = File.open( out_fn, "w" )
    for i in 0..xn-1
      fu.write cptemp[i, 0].round(2)
    for j in 1..yn-1
      fu.write ", "
      fu.write cptemp[i, j].round(2)
    end
      fu.write "\n"
    end
    for i in 0..xn-1
      fu.write csal[i, 0].round(2)
    for j in 1..yn-1
      fu.write ", "
      fu.write csal[i, j].round(2)
    end
      fu.write "\n"
    end
  fu.close
=begin
=end
