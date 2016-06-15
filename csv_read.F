      program csv_read
      implicit none
      integer, parameter:: xn=151, yn=151
      double precision tmp(xn,yn)
      integer i

      open ( 99, file="clim_lin.csv", status="old" )
      do i = 1,xn
        read( 99, * ) tmp(i,:)
      enddo
        write(*,*) maxval( tmp )
        write(*,*) minval( tmp )
      close( 99 )



      end program csv_read
