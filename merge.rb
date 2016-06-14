
require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

nc_fn =  Dir.glob( "./ncdf/*.nc" ).sort
  fnum = nc_fn.length

# set axis 
  time_arr = NArray.int( nc_fn.length )
  for n in 0..nc_fn.length-1
    #time_arr[n] = ()[].to_i
    time_arr[n] = (nc_fn[n]).split( "/" )[2].to_i
  end
  #p time_arr
  time_pts = { \
    "name" => "time", \
    "atts"=>{ "long_name"=> "date (yymm)", "units"=>""}, \
    "val" => time_arr \
  } 
  axp = GPhys::IO.open( nc_fn[0], "ptemp").get_axparts_k247
  axp[ "names" ].push( "time" )
  axp.store( "time", time_pts )

# read data
  xn, yn =  GPhys::IO.open( nc_fn[0], "ptemp").shape
  na_ptemp = NArrayMiss.sfloat( xn, yn, fnum )
  na_sal   = NArrayMiss.sfloat( xn, yn, fnum )
  na_rhoo  = NArrayMiss.sfloat( xn, yn, fnum )
nc_fn.each_with_index do | fn, t |
  p fn
  na_ptemp[0..-1, 0..-1, t] = GPhys::IO.open( fn, "ptemp").val
  na_sal[0..-1, 0..-1,   t] = GPhys::IO.open( fn, "sal" ).val
  na_rhoo[0..-1, 0..-1,  t] = GPhys::IO.open( fn, "rhoo").val
end

# output
  grid  = GPhys.restore_grid_k247( axp )
  rslt_fname =  "merged.nc"
  puts "output #{rslt_fname}"
  fu = NetCDF.create( rslt_fname )
  ["ptemp", "sal", "rhoo"].each do | vname |
    vap = VArray_proto_iwate.new( vname )
      vap.chg_val( eval("na_#{vname}") )
    vap = vap.get_varray( -999.99 )
    gp_new = GPhys.new( grid, vap )
    GPhys::NetCDF_IO.write( fu, gp_new )
  end
  fu.close

