
require "~/lib_k247/K247_basic"
require "~/Iwatemaru/lib_iwatemaru"

in_fn = "interpolated.nc"
  gp_csal   = GPhys::IO.open( in_fn, "csal")
  p gp_csal.max
  p gp_csal.min
