      program csv_read
      implicit none
      integer, parameter:: xn=301, yn=151
      double precision tmp(xn,yn), tmp2(yn)
      integer i,j

      open ( 99, file="clim_lin.csv", status="old" )
      do i = 1, xn
      !  read( 99, * ) tmp(i,:)
        read( 99, * ) tmp2(:)
        do j = 1, yn
          tmp(i,j) = tmp2(yn+1-j)
        enddo
      enddo
        write(*,*) maxval( tmp )
        write(*,*) minval( tmp )
      close( 99 )



      end program csv_read
