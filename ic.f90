subroutine getic(x,uc,up,ucsol)

  use doubleprecision
  use prms
  use conv

  implicit none

  real(kind = dp), intent(out) :: uc(3,0:n), up(3,0:n), ucsol(0:nsteps,3,0:n)
  real(kind = dp) :: x(0:n), udum(0:n)
  integer :: i

    forall(i=0:n:1) x(i) = i*h

    x(:) = x(:) - L/2.
    do i=0,n
        !! Gaussian pulse
        ! x(:) = x(:) - L/2.
        ! up(1,i) = amp * ( exp( -(x(i)**2.) ) + 1 )
        ! up(2,:) = 1; up(3,:) = 1./g

        !! Some sort of shock
        ! if (x(i) > 0 ) then
        !     up(1,i) = amp
        ! else
        !     up(1,i) = 2.*amp
        ! end if

        !! Sod Shock tube
        ! if (x(i) > 0 ) then
        !     up(1,i) = 0.125
        !     up(2,i) = 0.000
        !     up(3,i) = 0.100
        ! else
        !     up(1,i) = 1.000
        !     up(2,i) = 0.000
        !     up(3,i) = 1.000
        ! end if

        !! Shu-Osher
        ! print*, i,x(i)
        if (x(i) < -4.0 ) then
            up(1,i) = 27./7.
            up(2,i) = 4.*sqrt(35.)/7.0
            up(3,i) = 31./3.
        else
            up(1,i) = 1. + 0.2*sin(5*x(i))
            up(2,i) = 0.0
            up(3,i) = 1.0
        end if
    end do

    ! Smoothing
    udum(:) = up(1,:)
    do i = 1,n-1
        up(1,i) = 1./6.*(udum(i-1) + 4.*udum(i) + udum(i+1))
    end do

    call p_to_c(up,uc)
    call output(uc(1,:),x,'rho.',0)
    ucsol(0,:,:) = uc(:,:)

end subroutine getic
