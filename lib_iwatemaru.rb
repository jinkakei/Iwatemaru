
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
        when "ptemp"
          @lname = "potential temperature"
          @units = "degC"
        when "sal"
          @lname = "salinity"
          @units = "psu"
        when "rhoo"
          @lname = "potential density"
          @units = "kg.m-3"
        when "cptemp"
          @lname = "climatological potential temperature"
          @units = "degC"
        when "csal"
          @lname = "climatological salinity"
          @units = "psu"
        when "crhoo"
          @lname = "climatological potential density"
          @units = "kg.m-3"
        else
          puts "!ERROR! wrong var name #{@name} (CODE:160304_1747)"
          exit false
      end
    end # def set_attr

    def chg_name( name )
      @name = name
    end

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


  def set_axp_linterpolate( llon, ldep )

    axp_names = ["llon", "ldep"]
    x_pts = { \
      "name" => "llon", \
      "atts"=>{ "long_name"=> "longitude", "units"=>"deg"}, \
      "val" => llon \
    } 
    #  "atts"=>{ "long_name"=> "linearly interpolated longitude", "units"=>"deg"}, \
    z_pts = { \
      "name" => "ldep", \
      "atts"=>{ "long_name"=> "depth", "units"=>"m"}, \
      "val" => ldep \
    } 
    #  "atts"=>{ "long_name"=> "linearly interpolated depth", "units"=>"m"}, \
    axp = { "names"=> axp_names, \
            "llon"=> x_pts, "ldep"=> z_pts }
    return axp
  end # def nhm_set_axp
