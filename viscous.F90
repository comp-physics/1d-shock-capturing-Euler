subroutine viscosity(u,fin)

    use doublePrecision
    use prms

    implicit none

    real(kind = dp), intent(in)   :: u(3,0:n)
    real(kind = dp), intent(inout)  :: fin(3,0:n)
    real(kind = dp) :: uxx(3,0:n)
    real(kind = dp)               :: c(0:1)
    integer                       :: i

    c(0) = eps * (-2._dp)*hi**2
    c(1) = eps * (+1._dp)*hi**2

    uxx = 0.
    do i = 5,n-6
    uxx(:,i) = c(1)*u(:,i-1) + c(0)*u(:,i) + c(1)*u(:,i+1)
    end do

    fin = fin + uxx

end subroutine viscosity
