

require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

in_fn = "clim.nc"
  gp_cptemp = GPhys::IO.open( in_fn, "cptemp")
  gp_csal   = GPhys::IO.open( in_fn, "csal")
  gp_crhoo  = GPhys::IO.open( in_fn, "crhoo")

  xn, yn = gp_cptemp.shape
  lon = gp_cptemp.coord( 0 ).val
  dep = gp_cptemp.coord( 1 ).val
  miss_val = -999.99

# depth iterpolaction ( per dz )
  dz = 2.0
  lyn = ( dep.abs.max / dz ).to_i + 1
  ldep = dz * NArray.sfloat( lyn ).indgen * -1.0 + dep.max
  na_cptemp = gp_cptemp.val
  na_csal   = gp_csal.val
  na_crhoo  = gp_crhoo.val
  cptemp_dlin = NArray.sfloat( xn, lyn ).fill( miss_val )
  csal_dlin   = NArray.sfloat( xn, lyn ).fill( miss_val )
  crhoo_dlin  = NArray.sfloat( xn, lyn ).fill( miss_val )
  for i in 0..xn-1
  #for i in 2..2
    j_end = 0
  for j in 0..yn-2
    break if na_cptemp[i,j+1] < -100 # check missing
    j_bgn = j_end
    for j2 in j_end..lyn-2 
      j_end = j2
      break if (ldep[j2] >= dep[j+1])  and ( ldep[j2+1] < dep[j+1])
    end
    cptemp_dlin[i,j_bgn] = na_cptemp[i,j]
    csal_dlin[i,j_bgn] = na_csal[i,j]
    crhoo_dlin[i,j_bgn] = na_crhoo[i,j]
    #puts "#{dep[j]}m, #{cptemp_dlin[i,j_bgn]}"
    for j2 in j_bgn+1..j_end
      cptemp_dlin[i,j2] = \
        (  ( ldep[j2] -  dep[j+1] ) * na_cptemp[i,j] \
         + ( dep[j]   - ldep[j2]  ) * na_cptemp[i,j+1] \
        ) / (dep[j] - dep[j+1])
      csal_dlin[i,j2] = \
        (  ( ldep[j2] -  dep[j+1] ) * na_csal[i,j] \
         + ( dep[j]   - ldep[j2]  ) * na_csal[i,j+1] \
        ) / (dep[j] - dep[j+1])
      crhoo_dlin[i,j2] = \
        (  ( ldep[j2] -  dep[j+1] ) * na_crhoo[i,j] \
         + ( dep[j]   - ldep[j2]  ) * na_crhoo[i,j+1] \
        ) / (dep[j] - dep[j+1])
    #  puts "  #{ldep[j2]}m: #{cptemp_dlin[i,j2]}"
    end
  end
    if j_end == lyn-2
      cptemp_dlin[i,lyn-1] = na_cptemp[i,yn-1]
      csal_dlin[i,lyn-1] = na_csal[i,yn-1]
      crhoo_dlin[i,lyn-1] = na_crhoo[i,yn-1]
      j_end = lyn - 1
    end
  #  puts "#{lon[i]}E: org: #{na_cptemp[i,0..-1].min}, dint: #{cptemp_dlin[i,j_end]}" 
  end

# lon interpolate
  #dx = 0.01
  dx = 0.001
  lxn = ( ( lon[-1] - lon[0] ) / dx ).to_i + 1
  llon = dx * NArray.sfloat( lxn ).indgen + lon[0]
  cptemp_lin = NArray.sfloat( lxn, lyn ).fill( miss_val )
  csal_lin = NArray.sfloat( lxn, lyn ).fill( miss_val )
  crhoo_lin = NArray.sfloat( lxn, lyn ).fill( miss_val )
  for j in 0..lyn-1
    for i0 in 0..xn-1
      break if cptemp_dlin[i0,j] > -100
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
      cptemp_lin[i2,j] = \
        (  ( lon[i+1] - llon[i2]) * cptemp_dlin[i  ,j] \
         + ( llon[i2] - lon[i]  ) * cptemp_dlin[i+1,j] \
        ) / (lon[i+1] - lon[i])
      csal_lin[i2,j] = \
        (  ( lon[i+1] - llon[i2]) * csal_dlin[i  ,j] \
         + ( llon[i2] - lon[i]  ) * csal_dlin[i+1,j] \
        ) / (lon[i+1] - lon[i])
      crhoo_lin[i2,j] = \
        (  ( lon[i+1] - llon[i2]) * crhoo_dlin[i  ,j] \
         + ( llon[i2] - lon[i]  ) * crhoo_dlin[i+1,j] \
        ) / (lon[i+1] - lon[i])
    #  puts "  #{llon[i2]}E: #{cptemp_lin[i2,j]}"
    #  p cptemp_lin[i2,j]
    end
  end
    cptemp_lin[-1,j] = cptemp_dlin[-1,j]
    csal_lin[-1,j] = csal_dlin[-1,j]
    crhoo_lin[-1,j] = crhoo_dlin[-1,j]
  end


# output
  axp = GPhys::IO.open( in_fn, "cptemp").get_axparts_k247
  axp["dep"]["val"] = ldep
  axp["lon"]["val"] = llon
  grid  = GPhys.restore_grid_k247( axp )
  rslt_fname =  "clim_lin.nc"
  puts "output #{rslt_fname}"
  fu = NetCDF.create( rslt_fname )
  ["cptemp", "csal", "crhoo"].each do | vname |
    vap = VArray_proto_iwate.new( vname )
      vap.chg_val( eval("#{vname}_lin") )
      vap.chg_comnt( "linear interpolated" )
    vap = vap.get_varray( miss_val )
    gp_new = GPhys.new( grid, vap )
    GPhys::NetCDF_IO.write( fu, gp_new )
  end
  #  GPhys::NetCDF_IO.write( fu, gp_ptemp )
  #  GPhys::NetCDF_IO.write( fu, gp_sal   )
  #  GPhys::NetCDF_IO.write( fu, gp_rhoo )
  fu.close
=begin
=end
 


