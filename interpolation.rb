

require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

in_fn = "clim.nc"
  gp_cptemp = GPhys::IO.open( in_fn, "cptemp")
  gp_csal   = GPhys::IO.open( in_fn, "csal")
  gp_crhoo   = GPhys::IO.open( in_fn, "crhoo")

  xn, yn = gp_cptemp.shape
  lon = gp_cptemp.coord( 0 ).val
  dep = gp_cptemp.coord( 1 ).val
  miss_val = -999.99

# depth iterpolaction ( per 1m)
 lyn = ( dep.abs.max ).to_i + 1
 ldep = NArray.sfloat( lyn ).indgen * -1.0
 na_cptemp = gp_cptemp.val
 cptlin = NArray.sfloat( xn, lyn ).fill( miss_val )

 j_end = 0
 for i in 0..xn-1
 for j in 0..yn-2
   break if na_cptemp[i,j+1] < -100 # missing
   j_bgn = j_end
   for j2 in j_end..lyn-1 
     j_end = j2
     break if ldep[j2] == dep[j+1]
   end
   cptlin[i,j_bgn] = na_cptemp[i,j]
   #puts "#{dep[j]}m, #{cptlin[i,j_bgn]}"
   for j2 in j_bgn+1..j_end
     cptlin[i,j2] = \
       (  ( ldep[j2] -  dep[j+1] ) * na_cptemp[i,j] \
        + ( dep[j]   - ldep[j2]  ) * na_cptemp[i,j+1] \
       ) / (dep[j] - dep[j+1])
   #  puts "  #{ldep[j2]}m: #{cptlin[i,j2]}"
   end
 end
 end
   #puts "#{dep[j]}m, #{na_cptemp[i,j]}"
 
 # check interpolated field as merge.rb


 


