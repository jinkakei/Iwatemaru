require "~/lib_k247/K247_basic"

class Iwatemaru_admin
# file format -> end of class definition    

  attr_reader :line, :inames, :lon, :lat, :dep, :temp, :sal

  def initialize( fname )
    @fname = fname
    read_line( fname ) # @line
    get_item_name
    set_lonlat
    set_dep
    @missing = -999.99
    set_temperature
    set_salinity
    set_rhoo
  end
 # calc rhoo ( potential density )
  def set_rhoo
    calc_ptemp
    calc_rhoo
  end

    def calc_rhoo
      @rhoo = NArray.sfloat( @temp.shape[0], @temp.shape[1] ).fill( @missing )
      crhoo =  K247_calc_rhoo.new
      for i in 0..@temp.shape[0] -1
        crhoo.tharr = @ptemp[i,0..-1]
        crhoo.sarr  = @sal[i,0..-1]
        for j in 0..@temp.shape[1]-1
        if ( @temp[i,j] < -100 ) or ( @sal[i,j] < 0 )
          crhoo.tharr[j] = 0.0
          crhoo.sarr[j]  = 0.0
        end
        end
        pr =  crhoo.calc_rhoo_for_NArray
        for j in 0..@temp.shape[1]-1
        #if ( @temp[i,j] != @missing ) and ( @sal[i,j] != @missing )
        # ToDo: ?
        if ( @temp[i,j] > -100 ) and ( @sal[i,j] > 0 )
          @rhoo[i,j] = pr[j]
          #  puts "#{i}, #{j}: #{@temp[i,j]}, #{@sal[i,]}"
        end
        end
      end
      #p @rhoo
    end

    def calc_ptemp
      @ptemp = NArray.sfloat( @temp.shape[0], @temp.shape[1] ).fill( @missing )
      cptemp =  K247_calc_ptemp.new
        cptemp.parr = @dep[0..-1] * -1.0
      for i in 0..@temp.shape[0] -1
        cptemp.tarr = @temp[i,0..-1]
        cptemp.sarr = @sal[i,0..-1]
        pt =  cptemp.calc_ptemp_for_NArray
        for j in 0..@temp.shape[1]-1
        #if ( @temp[i,j] != @missing ) and ( @sal[i,j] != @missing )
        # ToDo: ?
        if ( @temp[i,j] > -100 ) and ( @sal[i,j] > 0 )
          @ptemp[i,j] = pt[j]
          #  puts "#{i}, #{j}: #{@temp[i,j]}, #{@sal[i,]}"
        end
        end
      end
      #p @ptemp
      #p @temp
    end

  # Initialize
    def read_line( fname )
      @line = []
      File.open( fname ) do | fu |
        fu.gets; fu.gets  # cut 1st, 2nd line ( Japanese )
        fu.each_line do | l |
          @line.push( l.chop )
        end
      end
    end

    def get_item_name
      @inames = []
      @line.each do | l |
        @inames.push( l.split( " " )[0] )
      end
    end

  # set_salinity
    def set_salinity
      j_bgn = search_inum( "SAL" ) + 1
      j_end = @inames.length - 1
      j_len = j_end - j_bgn
      @sal = NArray.sfloat( @lon.length, j_len+1 )
      for j in j_bgn..j_end
        @sal[0..-1, j-j_bgn] = get_divided_na( j )
      end
      #p @sal #[0..-1, -1]
    end

  # set_temperature
    def set_temperature
      j_bgn = search_inum( "TEMP" ) + 1
      j_end = search_inum( "SAL"  ) - 1
      j_len = j_end - j_bgn
      @temp = NArray.sfloat( @lon.length, j_len+1 )
      for j in j_bgn..j_end
        @temp[0..-1, j-j_bgn] = get_divided_na( j )
      end
    #  p @temp
    end

  # set_dep
    def set_dep
      j_bgn = search_inum( "TEMP" ) + 1
      j_end = search_inum( "SAL"  ) - 1
      j_len = j_end - j_bgn
      @dep = NArray.sfloat( j_len + 1 )
      for j in j_bgn..j_end
        @dep[j-j_bgn] = -1.0 * conv_dep( @inames[ j ] )
      end
      #p @dep
    end
      
      def conv_dep( txt )
      # "100m"
        return txt.to_f
      end

  # common
    def get_divided( inum )
      vals =  @line[ inum ].split( @inames[ inum ] )[1]
      txt_arr =  vals.split( " " )
      return txt_arr
    end

      def get_divided_na( inum )
        txt_arr = get_divided( inum )
        na = NArray.sfloat( txt_arr.length )
        for i in 0..txt_arr.length-1
          if txt_arr[i] != "none"
            na[i] = txt_arr[i].to_f
          else
            na[i] = @missing
          end
        end
        return na
      end

    def search_inum( iname )
      t_i = -1
      @inames.each_with_index do | item, i | 
        if item == iname
         t_i = i 
         break
        end
      end
      return t_i
    end

  # set_lonlat
    def set_lonlat
      set_lon
      set_lat
    end

      def set_lon
        lon_org = get_divided( search_inum( "LONG" ) )
        @lon = NArray.sfloat( lon_org.length )
        lon_org.each_with_index do | lorg, i |
          @lon[i] = conv_deg_to_num( lorg )
        end
      end
  
      def set_lat
        lat_org = get_divided( search_inum( "LAT" ) )
        @lat = NArray.sfloat( lat_org.length )
        lat_org.each_with_index do | lorg, i |
          @lat[i] = conv_deg_to_num( lorg )
        end
      end
  
      def conv_deg_to_num( deg_org )
      # "141-59"
          deg, min  = deg_org.split( "-" )
          return ( deg.to_f + ( min.to_f / 60.0 ).round(2) )
      end

# GPhys
  def ncdf_write
    yymm =  @fname.split( "_" )[1]
    @grid  = GPhys.restore_grid_k247( set_axp_iwate )
    rslt_fname = "#{yymm}.nc"
    puts "output #{rslt_fname}"
    fu = NetCDF.create( rslt_fname )
      [ "temp", "sal", "rhoo" ].each do | vname |
        gp_new = GPhys.new( @grid, get_gp( vname ) )
        GPhys::NetCDF_IO.write( fu, gp_new )
      end
    fu.close
=begin
=end
  end # ncdf_write

    def get_gp( vname )
    # OLD: nhm_set_psi, nhm_set_temp
      vap = VArray_proto_iwate.new( vname )
        vap.chg_val( eval("@#{vname}") )
      return vap.get_varray( @missing )
    end

  def set_axp_iwate
    axp_names = ["lon", "dep" ]
    x_pts = { \
      "name" => "lon", \
      "atts"=>{ "long_name"=> "longitude", "units"=>"deg"}, \
      "val" => @lon \
    } 
    z_pts = { \
      "name" => "dep", \
      "atts"=>{ "long_name"=> "depth", "units"=>"m"}, \
      "val" => @dep \
    } 
    axp = { "names"=> axp_names, \
            "lon"=> x_pts, "dep"=> z_pts }
    return axp
  end # def nhm_set_axp

end
# class Iwatemaru_admin


# class for NetCDF
  
  class VArray_proto_iwate
  # 2016-03-04: add "comment" to attributes
    def initialize( name )
      @name = name
      @val = ""
      # attrs
        @lname = ""
        @units = ""
        @comnt = ""
      set_attr # set attrs by @name
    end
    
    def set_attr
      case @name
        when "temp"
          @lname = "temperature"
          @units = "degC"
        when "sal"
          @lname = "salinity"
          @units = " "
        when "rhoo"
          @lname = "potential density"
          @units = " "
        else
          puts "!ERROR! wrong var name #{@name} (CODE:160304_1747)"
          exit false
      end
    end # def set_attr

    def chg_val( val )
      @val = val
    end

    def chg_lname( lname )
      @lname = lname
    end

    def chg_units( units )
      @units = units
    end

    def chg_comnt( comment )
      @comnt = comment
    end

    def get_varray( miss_val )
    #  missing_value = NArray.sfloat(1).fill( $miss_val )
      missing_value = NArray.sfloat(1).fill( miss_val )
          # $miss_val: define at exe_nhmodel.rb
          # 2016-05-28: under consideration
      if @comnt == "" then
        attr_now = { "long_name" => @lname, "units" => @units, \
                     "missing_value" => missing_value}
      else
        attr_now = { "long_name" => @lname, "units" => @units, \
                     "missing_value" => missing_value, \
                     "comment" => @comnt }
      end
      return VArray.new( @val, attr_now, @name )
    end
  end # class VArray_proto_iwate
# END: for GPhys

watcher = K247_Main_Watch.new

in_fn = "Iwatemaru/Iwatemaru_201108_Ozaki+Tsubakijima.dat"
  # text file made from PDF
iwa_adm = Iwatemaru_admin.new( in_fn )
  iwa_adm.ncdf_write

=begin
Dir.glob( "./Iwatemaru/*.dat" ).sort.each do | fn |
  Iwatemaru_admin.new( fn ).ncdf_write
# check: no problem for 2011~15/JJA
  #p Iwatemaru_admin.new( fn ).lon
  #p Iwatemaru_admin.new( fn ).lat
  #p Iwatemaru_admin.new( fn ).dep
end
=end


watcher.end_process
