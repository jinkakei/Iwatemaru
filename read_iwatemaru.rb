require "~/lib_k247/K247_basic"

class Iwatemaru_admin
# file format -> end of class definition    

  attr_reader :line, :inames

  def initialize( fname )
    read_line( fname ) # @line
    get_item_name
    set_lonlat
    @missing = -999.99
    set_temperature
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

  # set_temperature
    def set_temperature
      j_bgn = search_inum( "TEMP" ) + 1
      j_end = search_inum( "SAL" ) - 1
      j_len = j_end - j_bgn
      @temp = NArray.sfloat( @lon.length, j_len+1 )
      for j in j_bgn..j_end
        @temp[0..-1, j-j_bgn] = get_divided_na( j )
      end
      p @temp
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

end
# class Iwatemaru_admin

watcher = K247_Main_Watch.new

in_fn = "Iwatemaru/Iwatemaru_201106_Ozaki+Tsubakijima.dat"
  # text file made from PDF
#arr = read_line_Iwatemaru( in_fn )
iwa_adm = Iwatemaru_admin.new( in_fn )
#p iwa_adm.lon


watcher.end_process
