
require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

# cut
cname = "clim"
#cname = "201408"
in_fn = "#{cname}_lin.nc"
  #lon_min = 142.2; lon_max = 142.5
  lon_min = 142.1; lon_max = 142.5025
  gp_ptemp0   = GPhys::IO.open( in_fn, "ptemp_lin")
    gp_ptemp = gp_ptemp0.cut( "llon" => lon_min..lon_max )
  gp_sal0   = GPhys::IO.open( in_fn, "sal_lin")
    gp_sal = gp_sal0.cut( "llon" => lon_min..lon_max )
  gp_rhoo0  = GPhys::IO.open( in_fn, "rhoo_lin")
    gp_rhoo = gp_rhoo0.cut( "llon" => lon_min..lon_max )
  xn, yn = gp_ptemp.shape
  #DCL.gropn( 1 ) # 1: display, 2: pdf
  ##dcl.udpset( 'lmsg', false ) # erase "contour interval ..."
  #  tlevs = 1.0 * NArray.sfloat( 18 ).indgen + 2.0
  #  GGraph.tone( gp_ptemp, true, "levels"=> tlevs )
  #  slevs = 0.1 * NArray.sfloat( 11 ).indgen + 33.0
  #  GGraph.tone( gp_sal, true, "levels"=> slevs )
  #  rlevs = 0.2 * NArray.sfloat( 16 ).indgen + 23.8 # 23.8 ~ 26.7
  #  GGraph.tone( gp_rhoo, true, "levels"=> rlevs )
  #DCL.grcls
# 2016-06-15: caution! tentative, rhoo -> temp ( for current nhmodel.F)
  #temp = 10.0 + ( gp_rhoo.val - 25.25 ) * 0.001 / ( - 2.0 * 0.0001)
  #p temp
  #p temp.max
  #p temp.min
# 2016-06-16
  ptemp = gp_ptemp.val
  sal   = gp_sal.val
  out_fn = "#{cname}_lin.csv"
    puts "out_fn: #{out_fn}"
    puts "  xn = #{xn}, yn = #{yn}"
  fu = File.open( out_fn, "w" )
    for i in 0..xn-1
      fu.write ptemp[i, 0].round(2)
    for j in 1..yn-1
      fu.write ", "
      fu.write ptemp[i, j].round(2)
    end
      fu.write "\n"
    end
    for i in 0..xn-1
      fu.write sal[i, 0].round(2)
    for j in 1..yn-1
      fu.write ", "
      fu.write sal[i, j].round(2)
    end
      fu.write "\n"
    end
  fu.close
=begin
=end
