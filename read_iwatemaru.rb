require "~/lib_k247/K247_basic"

class Iwatemaru_admin
# file format -> end of class definition    

  attr_reader :line, :inames

  def initialize( fname )
    read_line( fname ) # @line
    get_item_name
    set_lonlat
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
      p @inames
    end

    def set_lonlat
      set_lon
      set_lat
    end

      def set_lon
        lon_org = get_divided( "LONG" )
        @lon = NArray.sfloat( lon_org.length )
        lon_org.each_with_index do | lorg, i |
          @lon[i] = conv_deg_to_num( lorg )
        end
      end
  
      def set_lat
        lat_org = get_divided( "LAT" )
        @lat = NArray.sfloat( lat_org.length )
        lat_org.each_with_index do | lorg, i |
          @lat[i] = conv_deg_to_num( lorg )
        end
        p @lat
      end
  
      def conv_deg_to_num( deg_org )
      # "141-59"
          deg, min  = deg_org.split( "-" )
          return ( deg.to_f + ( min.to_f / 60.0 ).round(2) )
      end

    def get_divided( iname )
      #
      t_i = search_inum( iname )
      vals =  @line[ t_i ].split( iname )[1]
      txt_arr =  vals.split( " " )
      return txt_arr
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
end
# class Iwatemaru_admin

watcher = K247_Main_Watch.new

in_fn = "Iwatemaru/Iwatemaru_201106_Ozaki+Tsubakijima.dat"
  # text file made from PDF
#arr = read_line_Iwatemaru( in_fn )
iwa_adm = Iwatemaru_admin.new( in_fn )
#p iwa_adm.lon


watcher.end_process
