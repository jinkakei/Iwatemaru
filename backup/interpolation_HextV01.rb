

require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"


cname = "clim"
#cname = "201408"
in_fn = "ncdf/#{cname}.nc"
if cname == "clim"
  gp_ptemp = GPhys::IO.open( in_fn, "cptemp")
  gp_sal   = GPhys::IO.open( in_fn, "csal")
  gp_rhoo  = GPhys::IO.open( in_fn, "crhoo")
else  
  gp_ptemp = GPhys::IO.open( in_fn, "ptemp")
  gp_sal   = GPhys::IO.open( in_fn, "sal")
  gp_rhoo  = GPhys::IO.open( in_fn, "rhoo")
end
  miss_val = -999.99

  xn0, yn0 = gp_ptemp.shape
  lon = gp_ptemp.coord( 0 ).val
  #dep = gp_ptemp.coord( 1 ).val
# 2016-06-16: test extrapolation
  xn = xn0
  yn = yn0 + 1
  exdep_max = -500.0
  dep0 = gp_ptemp.coord( 1 ).val
    dep = NArray.sfloat( yn0 + 1 )
    dep[0..-2] = dep0[0..-1]
    dep[-1] = exdep_max
  
  ptemp0 = gp_ptemp.val
  na_ptemp = NArray.sfloat(xn, yn).fill( miss_val )
  sal0 = gp_sal.val
  na_sal = NArray.sfloat(xn, yn).fill( miss_val )
  rhoo0 = gp_rhoo.val
  na_rhoo = NArray.sfloat(xn, yn).fill( miss_val )
  #  na_ptemp[0..-1, 0..-2] = ptemp0[0..-1, 0..-1]
  #  ! "cannot convert NArrayMiss to Float"
  # move data
  for i in 0..xn-1
  for j in 0..yn-2
    if ptemp0[i,j] > (miss_val+1)
      na_ptemp[i,j] = ptemp0[i,j] 
      na_sal[i,j] = sal0[i,j] 
      na_rhoo[i,j] = rhoo0[i,j]
    end
  end
  end
  # horizontal extrapolation
  # ! now, for Ozaki line only!
  #  puts "!CAUTION! tentative horizontal extrapolation@2016-06-18"
    i0 = 1; j0 = 8
    # horizontal extrapolation
    na_ptemp[i0,j0] = na_ptemp[i0+1,j0] \
                    + (na_ptemp[i0+2] - na_ptemp[i0+1]) \
                    *  ( lon[i0+1] - lon[i0] ) / (lon[i0+2] - lon[i0+1])
    na_sal[i0,j0] = na_sal[i0+1,j0] \
                    + (na_sal[i0+2] - na_sal[i0+1]) \
                    *  ( lon[i0+1] - lon[i0] ) / (lon[i0+2] - lon[i0+1])
    na_rhoo[i0,j0] = na_rhoo[i0+1,j0] \
                    + (na_rhoo[i0+2] - na_rhoo[i0+1]) \
                    *  ( lon[i0+1] - lon[i0] ) / (lon[i0+2] - lon[i0+1])
  #  # check h extrapolation
  #  p lon[i0..i0+3]
  #  for j in j0-1..j0+2
  #    puts "#{dep[j]}m: #{na_ptemp[i0,j].round(2)} #{na_ptemp[i0+1, j].round(2)}, #{na_ptemp[i0+2, j].round(2)}, #{na_ptemp[i0+3, j].round(2)}, " 
  #  end


  # vertical extrapolation
  for i in 0..xn-1
  for j in 1..yn-2
  # ToDo: if miss at j = 0?
    if na_ptemp[i,j+1] < miss_val+1
      na_ptemp[i,j+1] = na_ptemp[i,j] \
          + ( na_ptemp[i,j] - na_ptemp[i,j-1]) \
          * ( dep[j+1] - dep[j] ) / ( dep[j] - dep[j-1] )
      na_sal[i,j+1] = na_sal[i,j] \
          + ( na_sal[i,j] - na_sal[i,j-1]) \
          * ( dep[j+1] - dep[j] ) / ( dep[j] - dep[j-1] )
      na_rhoo[i,j+1] = na_rhoo[i,j] \
          + ( na_rhoo[i,j] - na_rhoo[i,j-1]) \
          * ( dep[j+1] - dep[j] ) / ( dep[j] - dep[j-1] )
    end
  end
    # check
    #for j in 0..yn-1
    #  puts "  #{dep[j]}m: #{na_ptemp[i,j].round(2)}"
    #end
  end
# End: 2016-06-16: test extrapolation


# depth iterpolaction ( per dz )
  #dz = 2.0
  dz = 5.0
  lyn = ( dep.abs.max / dz ).to_i + 1
  ldep = dz * NArray.sfloat( lyn ).indgen * -1.0 + dep.max
  #na_ptemp = gp_ptemp.val
  #na_sal   = gp_sal.val
  #na_rhoo  = gp_rhoo.val
  ptemp_dlin = NArray.sfloat( xn, lyn ).fill( miss_val )
  sal_dlin   = NArray.sfloat( xn, lyn ).fill( miss_val )
  rhoo_dlin  = NArray.sfloat( xn, lyn ).fill( miss_val )
  for i in 0..xn-1
  #for i in 2..2
    j_end = 0
  for j in 0..yn-2
    break if na_ptemp[i,j+1] < -100 # check missing
    j_bgn = j_end
    for j2 in j_end..lyn-2 
      j_end = j2
      break if (ldep[j2] >= dep[j+1])  and ( ldep[j2+1] < dep[j+1])
    end
    ptemp_dlin[i,j_bgn] = na_ptemp[i,j]
    sal_dlin[i,j_bgn] = na_sal[i,j]
    rhoo_dlin[i,j_bgn] = na_rhoo[i,j]
    #puts "#{dep[j]}m, #{ptemp_dlin[i,j_bgn]}"
    for j2 in j_bgn+1..j_end
      ptemp_dlin[i,j2] = \
        (  ( ldep[j2] -  dep[j+1] ) * na_ptemp[i,j] \
         + ( dep[j]   - ldep[j2]  ) * na_ptemp[i,j+1] \
        ) / (dep[j] - dep[j+1])
      sal_dlin[i,j2] = \
        (  ( ldep[j2] -  dep[j+1] ) * na_sal[i,j] \
         + ( dep[j]   - ldep[j2]  ) * na_sal[i,j+1] \
        ) / (dep[j] - dep[j+1])
      rhoo_dlin[i,j2] = \
        (  ( ldep[j2] -  dep[j+1] ) * na_rhoo[i,j] \
         + ( dep[j]   - ldep[j2]  ) * na_rhoo[i,j+1] \
        ) / (dep[j] - dep[j+1])
    #  puts "  #{ldep[j2]}m: #{ptemp_dlin[i,j2]}"
    end
  end
    if j_end == lyn-2
      ptemp_dlin[i,lyn-1] = na_ptemp[i,yn-1]
      sal_dlin[i,lyn-1] = na_sal[i,yn-1]
      rhoo_dlin[i,lyn-1] = na_rhoo[i,yn-1]
      j_end = lyn - 1
    end
  #  puts "#{lon[i]}E: org: #{na_ptemp[i,0..-1].min}, dint: #{ptemp_dlin[i,j_end]}" 
  end

# lon interpolate
  #dx = 0.01
  #dx = 0.001
  dx = 0.0025 # ~250m
    # 2016-06-18: 39.25N > 1 deg E ~ 86.4 km
  lxn = ( ( lon[-1] - lon[0] ) / dx ).to_i + 1
  llon = dx * NArray.sfloat( lxn ).indgen + lon[0]
  ptemp_lin = NArray.sfloat( lxn, lyn ).fill( miss_val )
  sal_lin = NArray.sfloat( lxn, lyn ).fill( miss_val )
  rhoo_lin = NArray.sfloat( lxn, lyn ).fill( miss_val )
  for j in 0..lyn-1
    for i0 in 0..xn-1
      break if ptemp_dlin[i0,j] > -100
    end
    for i2 in 0..lxn-2
      i_end = i2
      break if (llon[i2] <= lon[i0])  and ( llon[i2+1] > lon[i0])
    end
  for i in i0..xn-2
    i_bgn = i_end
    for i2 in i_bgn..lxn-2 
      i_end = i2
      break if (llon[i2] <= lon[i+1])  and ( llon[i2+1] > lon[i+1])
    end
    #puts "org: #{lon[i]}, #{lon[i+1]}, int: #{llon[i_bgn]}, #{llon[i_end]}"
    for i2 in i_bgn..i_end
      ptemp_lin[i2,j] = \
        (  ( lon[i+1] - llon[i2]) * ptemp_dlin[i  ,j] \
         + ( llon[i2] - lon[i]  ) * ptemp_dlin[i+1,j] \
        ) / (lon[i+1] - lon[i])
      sal_lin[i2,j] = \
        (  ( lon[i+1] - llon[i2]) * sal_dlin[i  ,j] \
         + ( llon[i2] - lon[i]  ) * sal_dlin[i+1,j] \
        ) / (lon[i+1] - lon[i])
      rhoo_lin[i2,j] = \
        (  ( lon[i+1] - llon[i2]) * rhoo_dlin[i  ,j] \
         + ( llon[i2] - lon[i]  ) * rhoo_dlin[i+1,j] \
        ) / (lon[i+1] - lon[i])
    #  puts "  #{llon[i2]}E: #{ptemp_lin[i2,j]}"
    #  p ptemp_lin[i2,j]
    end
  end
    ptemp_lin[-1,j] = ptemp_dlin[-1,j]
    sal_lin[-1,j] = sal_dlin[-1,j]
    rhoo_lin[-1,j] = rhoo_dlin[-1,j]
  end


# output
  #axp = GPhys::IO.open( in_fn, "ptemp").get_axparts_k247
  #axp["dep"]["val"] = ldep
  #axp["lon"]["val"] = llon
  axp = set_axp_linterpolate( llon, ldep )
  grid  = GPhys.restore_grid_k247( axp )
  rslt_fname =  "#{cname}_lin.nc"
  puts "output #{rslt_fname}"
  fu = NetCDF.create( rslt_fname )
  ["ptemp", "sal", "rhoo"].each do | vname |
    vap = VArray_proto_iwate.new( vname )
      vap.chg_name( "#{vname}_lin" )
      vap.chg_val( eval("#{vname}_lin") )
      vap.chg_comnt( "linear interpolated" )
    vap = vap.get_varray( miss_val )
    gp_new = GPhys.new( grid, vap )
    GPhys::NetCDF_IO.write( fu, gp_new )
  end
    GPhys::NetCDF_IO.write( fu, gp_ptemp )
    GPhys::NetCDF_IO.write( fu, gp_sal   )
    GPhys::NetCDF_IO.write( fu, gp_rhoo )
  fu.close
=begin
=end
 


