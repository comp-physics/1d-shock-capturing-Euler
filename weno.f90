module weno

contains

subroutine recon(fp,fm,f)

    use prms
    use doubleprecision

    implicit none

    real(kind = dp), intent(in) :: fp(3,0:n), fm(3,0:n)
    real(kind = dp) :: frp(3,0:n), frm(3,0:n)
    real(kind = dp), intent(out) :: f(3,0:n)
    integer :: i


    do i = 1,3
        if (enable_weno == 'True') then
            call reconstruct5(frp(i,:), fp(i,:), n,  1)
            call reconstruct5(frm(i,:), fm(i,:), n, -1)
            f(i,:) = frp(i,:) + frm(i,:)
        ! else
            ! f(i,:) = 0.5*(fp(i+1,:) + fm(i,:))
            ! f(i,:) = fm(i,:)
        end if
    end do


end subroutine recon

subroutine reconstruct3 (ur, u, n, bias)
! Equation numbers in the implementation refer to Liu, Osher, and Chan's paper.

    use doubleprecision

    implicit none

    integer, intent(in) :: n, bias
    real(kind = dp), intent(in) :: u(0:n)
    real(kind = dp), intent(out) :: ur(0:n)
    real(kind = dp), parameter :: eps = 1.d-6  ! guarantee nonzero denominator
    real(kind = dp) :: beta(1:2)               ! smoothness indicators
    real(kind = dp) :: w(1:2)                  ! nonlinear weights
    real(kind = dp) :: wt(1:2), wtsumi         ! temporary nonlinear weights
    real(kind = dp) :: urloc(1:2)              ! the two local reconstructions
    real(kind = dp) :: a(1:2,1:2)              ! weights in reconstruction
    integer :: i
    real(kind = dp) :: v(-1:n+2)               ! add on periodic bcs
    real(kind = dp) :: v0, vp, vm              ! local values

    a(1,1) = -1.d0 / 2.d0
    a(1,2) =  3.d0 / 2.d0
    a(2,1) =  1.d0 / 2.d0
    a(2,2) =  1.d0 / 2.d0

    ! Add on periodic boundary conditions
    ! this is wasteful but results in a single loop so the code is easier to read
    v(0:n) = u(0:n)
    v(-1)  = u(n-1)
    v(n+1:n+2) = u(1:2)

    if (bias > 0) then ! bias to the left, case 1 in section 3.5
        do i = 0, n, 1
            v0 = v(i)
            vp = v(i+1)
            vm = v(i-1)
            ! The reconstructed values at x(i+1/2) per p'(j), p'(j+1) from bottom of p205
            ! Note mistake in the p'j formula, i.e. (x-x).
            urloc(1) = a(1,1) * vm + a(1,2) * v0
            urloc(2) = a(2,1) * v0 + a(2,2) * vp
            ! Smoothness indicators from p206 just above equation 3.16
            beta(1) = (v0 - vm)**2
            beta(2) = (vp - v0)**2
            ! Compute nonlinear weights (3.17a)
            wt(1) = 0.5d0 / ((eps + beta(1))**2)
            wt(2) = 1.0d0 / ((eps + beta(2))**2)
            wtsumi = 1.d0 / (wt(1) + wt(2))
            w(1) = wt(1) * wtsumi
            w(2) = wt(2) * wtsumi
            ! Finally reconstruct, formula (3.16)
            ur(i) = w(1) * urloc(1) + w(2) * urloc(2)
        end do
    else ! biased to the right, case 2 in section 3.5
        do i = 1, n+1, 1
            v0 = v(i)
            vp = v(i+1)
            vm = v(i-1)
            ! The reconstructed values at x(i-1/2) per p'(j), p'(j+1) from bottom of p205
            ! Note mistake in the p'j formula, i.e. (x-x).
            urloc(1) = a(2,1) * vm + a(2,2) * v0
            urloc(2) = a(1,2) * v0 + a(1,1) * vp
            ! Smoothness indicators from p206 just above equation 3.16
            beta(1) = (v0 - vm)**2
            beta(2) = (vp - v0)**2
            ! Compute nonlinear weights (3.17a)
            wt(1) = 1.0d0 / ((eps + beta(1))**2)
            wt(2) = 0.5d0 / ((eps + beta(2))**2)
            wtsumi = 1.d0 / (wt(1) + wt(2))
            w(1) = wt(1) * wtsumi
            w(2) = wt(2) * wtsumi
            ! Finally reconstruct, formula (3.16)
            ur(i-1) = w(1) * urloc(1) + w(2) * urloc(2)
        end do
    end if

end subroutine reconstruct3

subroutine reconstruct5 (ur, u, n, bias)
    ! Equation numbers in the implementation refer to Shu's paper.

    use doubleprecision

    implicit none

    integer, intent(in) :: n, bias
    real(kind = dp), intent(in) :: u(0:n)
    real(kind = dp), intent(out) :: ur(0:n)
    real(kind = dp), parameter :: eps = 1.d-6  ! guarantee nonzero denominator
    real(kind = dp) :: beta(1:3)               ! smoothness indicators
    real(kind = dp) :: w(1:3)                  ! nonlinear weights
    real(kind = dp) :: wt(1:3), wtsumi         ! temporary nonlinear weights
    real(kind = dp) :: gam(1:3)                ! linear weights
    real(kind = dp) :: urloc(1:3)              ! the three local reconstructions
    real(kind = dp) :: a(1:3,1:3)              ! weights in reconstruction
    real(kind = dp) :: b(1:2)                  ! constants for beta computation
    integer :: i
    real(kind = dp) :: v(-2:n+3)               ! add on periodic bcs
    real(kind = dp) :: v0, vp, vpp, vm, vmm    ! local values

    a(1,1) = 1.d0 / 3.d0
    a(1,2) = -7.d0 / 6.d0
    a(1,3) = 11.d0 / 6.d0
    a(2,1) = -1.d0 / 6.d0
    a(2,2) = 5.d0 / 6.d0
    a(2,3) = 1.d0 / 3.d0
    a(3,1) = 1.d0 / 3.d0
    a(3,2) = 5.d0 / 6.d0
    a(3,3) = -1.d0 / 6.d0

    b(1) = 13.d0 / 12.d0
    b(2) = 1.d0 / 4.d0
    ! just below (2.15)
    gam(1) = 1.d0 / 10.d0
    gam(2) = 3.d0 / 5.d0
    gam(3) = 3.d0 / 10.d0

    ! add on periodic boundary condition
    ! this is wasteful but results in a single loop so the code is easier to read
    v(0:n) = u(0:n)
    v(-2:-1) = u(n-2:n-1)
    v(n+1:n+3) = u(1:3)

    if (bias > 0) then ! bias to the left
        do i = 0, n, 1
            v0 = v(i)
            vp = v(i+1)
            vpp = v(i+2)
            vm = v(i-1)
            vmm = v(i-2)
            ! The three reconstructed values at x(i+1/2)
            ! Formulas (2.11), (2.12), (2.13)
            urloc(1) = a(1,1) * vmm + a(1,2) * vm + a(1,3) * v0
            urloc(2) = a(2,1) * vm + a(2,2) * v0 + a(2,3) * vp
            urloc(3) = a(3,1) * v0 + a(3,2) * vp + a(3,3) * vpp
            ! Smoothness indicators, formula (2.17)
            beta(1) = b(1) * (vmm - 2.d0 * vm + v0)**2 + b(2) * (vmm - 4.d0 * vm + 3.d0 * v0)**2
            beta(2) = b(1) * (vm - 2.d0 * v0 + vp)**2 + b(2) * (vm - vp)**2
            beta(3) = b(1) * (v0 - 2.d0 * vp + vpp)**2 + b(2) * (3.d0 * v0 - 4.d0 * vp + vpp)**2
            ! Compute nonlinear weights (2.10)
            wt(1) = gam(1) / ((eps + beta(1))**2)
            wt(2) = gam(2) / ((eps + beta(2))**2)
            wt(3) = gam(3) / ((eps + beta(3))**2)
            wtsumi = 1.d0 / (wt(1) + wt(2) + wt(3))
            w(1) = wt(1) * wtsumi
            w(2) = wt(2) * wtsumi
            w(3) = wt(3) * wtsumi
            ! Finally reconstruct, formula (2.16)
            ur(i) = w(1) * urloc(1) + w(2) * urloc(2) + w(3) * urloc(3)
        end do
    else ! biased to the right
        do i = 1, n+1, 1
            v0 = v(i)
            vp = v(i+1)
            vpp = v(i+2)
            vm = v(i-1)
            vmm = v(i-2)
            ! The three reconstructed values at x(i-1/2)
            ! Slightly different formulas than (2.11), (2.12), (2.13)
            urloc(1) = a(2,1) * vmm + a(2,2) * vm + a(2,3) * v0
            urloc(2) = a(3,1) * vm + a(3,2) * v0 + a(3,3) * vp
            urloc(3) = a(1,3) * v0 + a(1,2) * vp + a(1,1) * vpp
            ! Smoothness indicators, formula (2.17)
            beta(1) = b(1) * (vmm - 2.d0 * vm + v0)**2 + b(2) *( vmm - 4.d0 * vm + 3.d0 * v0)**2
            beta(2) = b(1) * (vm - 2.d0 * v0 + vp)**2 + b(2) * (vm - vp)**2
            beta(3) = b(1) * (v0 - 2.d0 * vp + vpp)**2 + b(2) * (3.d0 * v0 - 4.d0 * vp + vpp)**2
            ! Compute nonlinear weights (2.10)
            wt(1) = gam(3) / ((eps + beta(1))**2)
            wt(2) = gam(2) / ((eps + beta(2))**2)
            wt(3) = gam(1) / ((eps + beta(3))**2)
            wtsumi = 1.d0 / (wt(1) + wt(2) + wt(3))
            w(1) = wt(1) * wtsumi
            w(2) = wt(2) * wtsumi
            w(3) = wt(3) * wtsumi
            ! Finally reconstruct! Formula (2.16)
            ur(i-1) = w(1) * urloc(1) + w(2) * urloc(2) + w(3) * urloc(3)
        END DO
    END IF
END SUBROUTINE reconstruct5

end module weno
