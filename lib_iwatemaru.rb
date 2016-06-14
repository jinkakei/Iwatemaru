
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
