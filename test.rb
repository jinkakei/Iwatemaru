
require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

# cut
#=begin
#in_fn = "interpolated.nc"
in_fn = "interpolated_dx200mdz2m.nc"
  lon_min = 142.2; lon_max = 142.5
  gp_cptemp0   = GPhys::IO.open( in_fn, "cptemp")
    gp_cptemp = gp_cptemp0.cut( "lon" => lon_min..lon_max )
  gp_csal0   = GPhys::IO.open( in_fn, "csal")
    gp_csal = gp_csal0.cut( "lon" => lon_min..lon_max )
  gp_crhoo0  = GPhys::IO.open( in_fn, "crhoo")
    gp_crhoo = gp_crhoo0.cut( "lon" => lon_min..lon_max )
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
  temp = 10.0 + ( gp_crhoo.val - 25.25 ) * 0.001 / ( - 2.0 * 0.0001)
  #p temp
  #p temp.max
  #p temp.min
  out_fn = "clim_lin.dat"
    puts "out_fn: #{out_fn}"
    puts "  xn = #{xn}, yn = #{yn}"
  fu = File.open( out_fn, "w" )
    for i in 0..xn-1
      fu.write temp[i, 0].round(2)
    for j in 1..yn-1
    #for j in 1..5
      fu.write ", "
      fu.write temp[i, j].round(2)
    end
      fu.write "\n"
    end
  fu.close
#=end


# for report@2016-06-15
=begin
in_fn = "clim.nc"
  gp_cptemp   = GPhys::IO.open( in_fn, "cptemp")
  gp_ptemp  =  GPhys::IO.open( in_fn, "ptemp")
  gp_csal   = GPhys::IO.open( in_fn, "csal")
  gp_sal  =  GPhys::IO.open( in_fn, "sal")
  gp_crhoo   = GPhys::IO.open( in_fn, "crhoo")
  gp_rhoo  =  GPhys::IO.open( in_fn, "rhoo")
    time_arr = gp_sal.coord( 2 ).val; nt = time_arr.length
    p gp_sal.max
    p gp_sal.min

  DCL.gropn( 2 ) # 1: display, 2: pdf
  #  GGraph.set_fig( 'viewport'=>[0.15, 0.65, 0.10, 0.60] )
    GGraph.set_fig( 'viewport'=>[0.1, 0.85, 0.15, 0.8] )
    DCL.udpset( 'lmsg', false ) # erase "contour interval ..."
    tlevs = 1.0 * NArray.sfloat( 20 ).indgen + 0.0
    slevs = 0.1 * NArray.sfloat( 31 ).indgen + 32.4
    rlevs = 0.1 * NArray.sfloat( 31 ).indgen + 23.8
  # ouput
    GGraph.tone( gp_cptemp, true, "levels"=> tlevs, "title"=>gp_cptemp.long_name )
    GGraph.contour( gp_cptemp, false, "levels"=> tlevs, "index"=>3 )
      GGraph.color_bar
    for t in 0..nt-1
    #for t in 0..0
      GGraph.tone( gp_ptemp.cut( "time" => time_arr[t] ), true, "levels"=> tlevs, "title" => "#{gp_ptemp.long_name}: #{time_arr[t].to_s}" )
      GGraph.contour( gp_ptemp.cut( "time" => time_arr[t] ), false, "levels"=> tlevs, "index"=>3 )
        GGraph.color_bar
    end
    GGraph.tone( gp_csal, true, "levels"=> slevs, "title"=>gp_csal.long_name )
    GGraph.contour( gp_csal, false, "levels"=> slevs, "index"=>3 )
      GGraph.color_bar
    for t in 0..nt-1
    #for t in 0..0
      GGraph.tone( gp_sal.cut(   "time" => time_arr[t] ), true, "levels"=> slevs, "title" => "#{gp_sal.long_name}: #{time_arr[t].to_s}" )
      GGraph.contour( gp_sal.cut( "time" => time_arr[t] ), false, "levels"=> slevs, "index"=>3 )
        GGraph.color_bar
    end
    GGraph.tone( gp_crhoo, true, "levels"=> rlevs, "title"=>gp_crhoo.long_name )
    GGraph.contour( gp_crhoo, false, "levels"=> rlevs, "index"=>3 )
      GGraph.color_bar
    for t in 0..nt-1
    #for t in 0..0
      GGraph.tone( gp_rhoo.cut(  "time" => time_arr[t] ), true, "levels"=> rlevs, "title" => "#{gp_rhoo.long_name}: #{time_arr[t].to_s}" )
      GGraph.contour( gp_rhoo.cut( "time" => time_arr[t] ), false, "levels"=> rlevs, "index"=>3 )
        GGraph.color_bar
    end
  # clim
#    GGraph.tone( gp_cptemp, true, "levels"=> tlevs, "title"=>gp_cptemp.long_name )
#    GGraph.contour( gp_cptemp, false, "levels"=> tlevs, "index"=>3 )
#      GGraph.color_bar
#    GGraph.tone( gp_csal, true, "levels"=> slevs, "title"=>gp_csal.long_name )
#    GGraph.contour( gp_csal, false, "levels"=> slevs, "index"=>3 )
#      GGraph.color_bar
#    GGraph.tone( gp_crhoo, true, "levels"=> rlevs, "title"=>gp_crhoo.long_name )
#    GGraph.contour( gp_crhoo, false, "levels"=> rlevs, "index"=>3 )
#      GGraph.color_bar
#  for t in 0..nt-1
#  #for t in 0..0
#    GGraph.tone( gp_ptemp.cut( "time" => time_arr[t] ), true, "levels"=> tlevs, "title" => "#{gp_ptemp.long_name}: #{time_arr[t].to_s}" )
#    GGraph.contour( gp_ptemp.cut( "time" => time_arr[t] ), false, "levels"=> tlevs, "index"=>3 )
#      GGraph.color_bar
#    GGraph.tone( gp_sal.cut(   "time" => time_arr[t] ), true, "levels"=> slevs, "title" => "#{gp_sal.long_name}: #{time_arr[t].to_s}" )
#    GGraph.contour( gp_sal.cut( "time" => time_arr[t] ), false, "levels"=> slevs, "index"=>3 )
#      GGraph.color_bar
#    GGraph.tone( gp_rhoo.cut(  "time" => time_arr[t] ), true, "levels"=> rlevs, "title" => "#{gp_rhoo.long_name}: #{time_arr[t].to_s}" )
#    GGraph.contour( gp_rhoo.cut( "time" => time_arr[t] ), false, "levels"=> rlevs, "index"=>3 )
#      GGraph.color_bar
#  end
  DCL.grcls
=end
