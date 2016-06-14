
require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

nc_fn = "merged.nc"
  gp_ptemp = GPhys::IO.open( nc_fn, "ptemp")
  gp_sal   = GPhys::IO.open( nc_fn, "sal")
  gp_rhoo   = GPhys::IO.open( nc_fn, "rhoo")
  xn, yn, tn = gp_ptemp.shape

miss_val = -999.99
cptemp = NArray.sfloat( xn, yn ).fill( miss_val )
csal   = NArray.sfloat( xn, yn ).fill( miss_val )
crhoo  = NArray.sfloat( xn, yn ).fill( miss_val )
for i in 0..xn-1
for j in 0..yn-1
  tnow = tn
  onoff = NArray.sfloat( tn ).fill( 1.0 )
  for t in 0..tn-1
    if gp_ptemp.val[i,j,t] < -100 or gp_sal.val[i,j,t] < 0
      tnow = tnow - 1
      onoff[t] = 0.0
    end
  end
  if tnow > 1
    cptemp[i,j] = ( gp_ptemp.val[i,j,0..-1] * onoff[0..-1] ).sum / tnow
    csal[  i,j] = ( gp_sal.val[  i,j,0..-1] * onoff[0..-1] ).sum / tnow
    crhoo[ i,j] = ( gp_rhoo.val[ i,j,0..-1] * onoff[0..-1] ).sum / tnow
  end
end    
end
  #p ctclim



# output
  axp = GPhys::IO.open( "./ncdf/201106.nc", "ptemp").get_axparts_k247
  grid  = GPhys.restore_grid_k247( axp )
  rslt_fname =  "clim.nc"
  puts "output #{rslt_fname}"
  fu = NetCDF.create( rslt_fname )
  ["cptemp", "csal", "crhoo"].each do | vname |
    vap = VArray_proto_iwate.new( vname )
      vap.chg_val( eval("#{vname}") )
    vap = vap.get_varray( -999.99 )
    gp_new = GPhys.new( grid, vap )
    GPhys::NetCDF_IO.write( fu, gp_new )
  end
    GPhys::NetCDF_IO.write( fu, gp_ptemp )
    GPhys::NetCDF_IO.write( fu, gp_sal   )
    GPhys::NetCDF_IO.write( fu, gp_rhoo )
  fu.close
